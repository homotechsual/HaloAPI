#Requires -Version 7
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
    Write-Debug "Input:`n$($BatchInput | ConvertTo-Json -AsArray -Depth 5)"
    Write-Debug "Entity type: $EntityType"
    Write-Debug "Operation: $Operation"
    $BatchInput | ForEach-Object {
        if ($Batch[$BatchGroup].Count -ge $Size) {
            $Batch.Add([System.Collections.Generic.List[Object]]::New()) | Out-Null
            $BatchGroup++
        }
        $Batch[$BatchGroup].Add($_) | Out-Null
    }
    # Iterate over the batches, process each batch and then wait $Wait seconds before the next batch.
    Write-Debug "Batch:`n$($Batch | ConvertTo-Json -AsArray -Depth 5)"
    $CommandName = "$($Operation)-Halo$($EntityType)"
    $CommandExists = Get-Command -Name $CommandName
    $ModulePath = $MyInvocation.MyCommand.Module.Path
    Write-Debug "Module Path: $ModulePath"
    $Batch | ForEach-Object {
        $_ | ForEach-Object -Parallel {
            Import-Module $Using:ModulePath
            $HaloConnectionParams = @{
                URL = $Using:HAPIConnectionInformation.URL
                ClientID = $Using:HAPIConnectionInformation.ClientID
                ClientSecret = $Using:HAPIConnectionInformation.ClientSecret
                Scopes = $Using:HAPIConnectionInformation.AuthScopes
                Tenant = $Using:HAPIConnectionInformation.Tenant
                AdditionalHeaders = $Using:HAPIConnectionInformation.AdditionalHeaders
            }
            if ($DebugPreference -eq 'Continue') {
                $HaloConnectionParams.Debug = $True
            }
            if ($VerbosePreference -eq 'Continue') {
                $HaloConnectionParams.Verbose = $True
            }
            Connect-HaloAPI @HaloConnectionParams
            $LocalBatchResults = $using:BatchResults
            $CommandParameters = @{
                $Using:EntityType = $_
            }
            if ($DebugPreference -eq 'Continue') {
                $CommandParameters.Debug = $True
            }
            if ($VerbosePreference -eq 'Continue') {
                $CommandParameters.Verbose = $True
            }
            if ($Using:CommandExists) {
                [PSCustomObject]$Result = & $Using:CommandName @CommandParameters
                $LocalBatchResults.Add($Result)
            } else {
                Write-Error "The command $CommandName doesn't exist or isn't loaded."
            }
        }
        if ($Batch.Count -ge 2) {
            Write-Verbose "More than one batch found, waiting $Wait seconds before the next batch runs." 
            Start-Sleep -Seconds $Wait
        }
    }
    Return $BatchResults
}