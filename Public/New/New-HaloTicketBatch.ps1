Function New-HaloTicketBatch {
    <#
        .SYNOPSIS
            Creates multiple tickets via the Halo API.
        .DESCRIPTION
            Function to send a batch of ticket creation requests to the Halo API
        .OUTPUTS
            Outputs an object containing the responses from the web requests.
    #>
    [CmdletBinding( SupportsShouldProcess = $True )]
    [OutputType([Object[]])]
    Param (
        # Array of objects containing properties and values used to create one or more new tickets.
        [Parameter( Mandatory = $True )]
        [Array[]]$Tickets
    )
    Invoke-HaloPreFlightCheck
    try {
        if ($PSCmdlet.ShouldProcess('Tickets', 'Create')) {
            if ($Tickets -is [Array]) {
                $BatchResults = [System.Collections.Concurrent.ConcurrentBag[PSObject]]::New()
                $Tickets | ForEach-Object -Parallel {
                    Import-Module 'X:\Development\Repositories\MJCO\HaloAPI\HaloAPI.psm1'
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
                    [PSCustomObject]$Ticket = New-HaloTicket -Ticket $_
                    $LocalBatchResults.Add($Ticket)
                }
                Return $BatchResults
            } else {
                throw 'New-HaloTicketBatch requires an array of tickets to create.'
            }  
        }
    } catch {
        New-HaloError -ErrorRecord $_
    }
}