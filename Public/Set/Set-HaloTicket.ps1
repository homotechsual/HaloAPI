Function Set-HaloTicket {
    <#
        .SYNOPSIS
            Updates one or more tickets via the Halo API.
        .DESCRIPTION
            Function to send a ticket update request to the Halo API
        .OUTPUTS
            Outputs an object containing the response from the web request.
    #>
    [CmdletBinding( SupportsShouldProcess = $True )]
    [OutputType([Object[]])]
    Param (
        # Object or array of objects containing properties and values used to update one or more existing tickets.
        [Parameter( Mandatory = $True, ValueFromPipeline )]
        [Object[]]$Ticket,
        # Skip validation checks.
        [Parameter()]
        [Switch]$SkipValidation
    )
    Invoke-HaloPreFlightCheck
    try {
        $ObjectToUpdate = $Ticket | ForEach-Object {
            if ($null -eq $_.id) {
                throw 'Ticket ID is required.'
            }
            $HaloTicketParams = @{
                TicketId = $_.id
            }
            if (-not $SkipValidation) {
                $TicketExists = Get-HaloTicket @HaloTicketParams
                if ($TicketExists) {
                    Return $True
                } else {
                    Return $False
                }
            } else {
                Write-Verbose 'Skipping validation checks.'
                return $True
            }
        }
        if ($False -notin $ObjectToUpdate) {
            if ($PSCmdlet.ShouldProcess($Ticket -is [Array] ? 'Tickets' : 'Ticket', 'Update')) {
                New-HaloPOSTRequest -Object $Ticket -Endpoint 'tickets'
            }
        } else {
            Throw 'One or more tickets was not found in Halo to update.'
        }
    } catch {
        New-HaloError -ErrorRecord $_
    }
}