Function New-HaloTicket {
    <#
        .SYNOPSIS
            Creates one or more tickets via the Halo API.
        .DESCRIPTION
            Function to send a ticket creation request to the Halo API
        .OUTPUTS
            Outputs an object containing the response from the web request.
    #>
    [CmdletBinding( SupportsShouldProcess = $True )]
    [OutputType([Object[]])]
    Param (
        # Object or array of objects containing properties and values used to create one or more new tickets.
        [Parameter( Mandatory = $True )]
        [Object[]]$Tickets
    )
    Invoke-HaloPreFlightCheck
    try {
        if ($PSCmdlet.ShouldProcess('Tickets', 'Create')) {
            if ($Ticket -is [Array]) {
                $BatchResults = [System.Collections.Concurrent.ConcurrentBag[PSObject]]::New()
                $Ticket | ForEach-Object -Parallel {
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