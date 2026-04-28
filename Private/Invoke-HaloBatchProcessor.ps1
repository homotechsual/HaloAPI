#Requires -Version 7
function Invoke-HaloBatchItem {
    [CmdletBinding()]
    [OutputType([Object])]
    param (
        [Parameter( Mandatory )]
        [Object]$BatchItem,
        [Parameter( Mandatory )]
        [String]$EntityType,
        [Parameter( Mandatory )]
        [String]$CommandName,
        [Parameter( Mandatory )]
        [Boolean]$CommandExists,
        [Object]$Parameters,
        [Parameter( Mandatory )]
        [Object]$ConnectionInformation
    )

    $HaloConnectionParams = @{
        URL = $ConnectionInformation.URL
        ClientID = $ConnectionInformation.ClientID
        ClientSecret = $ConnectionInformation.ClientSecret
        Scopes = $ConnectionInformation.AuthScopes
        Tenant = $ConnectionInformation.Tenant
        AdditionalHeaders = $ConnectionInformation.AdditionalHeaders
    }
    if ($DebugPreference -eq 'Continue') {
        $HaloConnectionParams.Debug = $True
    }
    if ($VerbosePreference -eq 'Continue') {
        $HaloConnectionParams.Verbose = $True
    }
    Connect-HaloAPI @HaloConnectionParams

    $CommandParameters = @{
        $EntityType = $BatchItem
    }
    if ($Parameters) {
        foreach ($Parameter in $Parameters.GetEnumerator()) {
            $CommandParameters[$Parameter.Key] = $Parameter.Value
        }
    }
    if ($DebugPreference -eq 'Continue') {
        $CommandParameters.Debug = $True
    }
    if ($VerbosePreference -eq 'Continue') {
        $CommandParameters.Verbose = $True
    }

    if ($CommandExists) {
        return [PSCustomObject](& $CommandName @CommandParameters)
    }

    Write-Error ('The command {0} doesn''t exist or isn''t loaded.' -f $CommandName)
}

function Invoke-HaloBatchProcessor {
    <#
    .SYNOPSIS
        Handles batch processing Halo API requests using PowerShell parallel processing.
    .DESCRIPTION
        Utility function to batch process Halo API requests supports configurable batch sizes and delays.
    .OUTPUTS
        Outputs an object containing the response(s) from the web request.
    #>
    [CmdletBinding()]
    [OutputType([Object[]])]
    param (
        # The input objects to split into batches and process.
        [Parameter( Mandatory )]
        [Object[]]$BatchInput,
        # The Halo entity suffix used to build the target command name.
        [Parameter( Mandatory )]
        [String]$EntityType,
        # The verb to invoke for each batched command.
        [Parameter( Mandatory )]
        [ValidateSet('New', 'Set', 'Remove')]
        [String]$Operation,
        # Additional command parameters reserved for future batch-processing options.
        [Object]$Parameters,
        # The number of items to include in each batch.
        [Int32]$Size = 100,
        # The delay in seconds between batches when more than one batch exists.
        [Int32]$Wait = 30
    )
    $BatchResults = [System.Collections.Concurrent.ConcurrentBag[PSObject]]::New()
    $Batch = [System.Collections.Generic.List[Object]]::New()
    $Batch.Add([System.Collections.Generic.List[Object]]::New()) | Out-Null
    # Break $Input into an assoc. array of $Size-sized batches.
    $BatchGroup = 0
    Write-Debug ('Input:{0}{1}' -f [Environment]::NewLine, ($BatchInput | ConvertTo-Json -AsArray -Depth 5))
    Write-Debug ('Entity type: {0}' -f $EntityType)
    Write-Debug ('Operation: {0}' -f $Operation)
    $BatchInput | ForEach-Object {
        if ($Batch[$BatchGroup].Count -ge $Size) {
            $Batch.Add([System.Collections.Generic.List[Object]]::New()) | Out-Null
            $BatchGroup++
        }
        $Batch[$BatchGroup].Add($_) | Out-Null
    }
    # Iterate over the batches, process each batch and then wait $Wait seconds before the next batch.
    Write-Debug ('Batch:{0}{1}' -f [Environment]::NewLine, ($Batch | ConvertTo-Json -AsArray -Depth 5))
    $CommandName = ('{0}-Halo{1}' -f $Operation, $EntityType)
    $CommandExists = Get-Command -Name $CommandName
    $ModulePath = $MyInvocation.MyCommand.Module.Path
    Write-Debug ('Module Path: {0}' -f $ModulePath)
    $Batch | ForEach-Object {
        $_ | ForEach-Object -Parallel {
            Import-Module $Using:ModulePath
            $LocalBatchResults = $using:BatchResults
            $Result = Invoke-HaloBatchItem -BatchItem $_ -EntityType $Using:EntityType -CommandName $Using:CommandName -CommandExists ([bool]$Using:CommandExists) -Parameters $Using:Parameters -ConnectionInformation $Using:HAPIConnectionInformation
            if ($null -ne $Result) {
                $LocalBatchResults.Add($Result)
            }
        }
        if ($Batch.Count -ge 2) {
            Write-Verbose ('More than one batch found, waiting {0} seconds before the next batch runs.' -f $Wait)
            Start-Sleep -Seconds $Wait
        }
    }
    Return $BatchResults
}