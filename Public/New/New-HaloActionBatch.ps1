Function New-HaloActionBatch {
    <#
        .SYNOPSIS
            Creates multiple actions via the Halo API.
        .DESCRIPTION
            Function to send a batch of action creation requests to the Halo API
        .OUTPUTS
            Outputs an object containing the responses from the web requests.
    #>
    [CmdletBinding( SupportsShouldProcess = $True )]
    [OutputType([Object[]])]
    Param (
        # Array of objects containing properties and values used to create one or more new actions.
        [Parameter( Mandatory = $True )]
        [Array[]]$Actions
    )
    Invoke-HaloPreFlightCheck
    try {
        if ($PSCmdlet.ShouldProcess('Actions', 'Create')) {
            if ($Actions -is [Array]) {
                $BatchResults = [System.Collections.Concurrent.ConcurrentBag[PSObject]]::New()
                $Actions | ForEach-Object -Parallel {
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
                    [PSCustomObject]$Action = New-HaloAction -Action $_
                    $LocalBatchResults.Add($Action)
                }
                Return $BatchResults
            } else {
                throw 'New-HaloActionBatch requires an array of actions to create.'
            }  
        }
    } catch {
        New-HaloError -ErrorRecord $_
    }
}