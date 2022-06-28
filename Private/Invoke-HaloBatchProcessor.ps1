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
        [Parameter( Mandatory )]
        [Object[]]$Input,
        [Parameter( Mandatory )]
        [String]$EntityType,
        [Parameter( Mandatory )]
        [ValidateSet('New', 'Set', 'Remove')]
        [String]$Operation,
        [Object]$Parameters,
        [Int32]$Size = 100,
        [Int32]$Wait = 1
    )
    $BatchResults = [System.Collections.Concurrent.ConcurrentBag[PSObject]]::New()
    $Batch = [System.Collections.Generic.List[Object]]::New()
    $Batch.Add([System.Collections.Generic.List[Object]]::New()) | Out-Null
    # Break $Input into an assoc. array of $Size-sized batches.
    $BatchGroup = 0
    $Input | ForEach-Object {  
        $Batch[$BatchGroup].Add($Input) | Out-Null
        if ($Batch[$BatchGroup].Count -ge $Size) {
            $Batch.Add([System.Collections.Generic.List[Object]]::New()) | Out-Null
            $BatchGroup++
        }
    }
    # Iterate over the batches, process each batch and then wait $Wait seconds before the next batch.
    $Batch | ForEach-Object {
        $_ | ForEach-Object -Parallel {
            Import-Module -Name 'HaloAPI'
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
                $EntityType = $_
            }
            if ($DebugPreference -eq 'Continue') {
                $CommandParameters.Debug = $True
            }
            if ($VerbosePreference -eq 'Continue') {
                $CommandParameters.Verbose = $True
            }
            $CommandName = "$Operation-Halo$EntityType"
            $CommandExists = Get-Command -Name $CommandName
            if ($CommandExists) {
                [PSCustomObject]$Result = & $CommandName @CommandParameters
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