Function Set-HaloTicketType {
    <#
        .SYNOPSIS
            Updates a ticket type via the Halo API.
        .DESCRIPTION
            Function to send a ticket type update request to the Halo API
        .OUTPUTS
            Outputs an object containing the response from the web request.
    #>
    [CmdletBinding( SupportsShouldProcess = $True )]
    [OutputType([Object])]
    Param (
        # Object containing properties and values used to update an existing ticket type.
        [Parameter( Mandatory = $True, ValueFromPipeline )]
        [Object]$TicketType
    )
    Invoke-HaloPreFlightCheck
    try {
        $ObjectToUpdate = Get-HaloTicketType -TicketTypeID $TicketType.id
        if ($ObjectToUpdate) {
            if ($PSCmdlet.ShouldProcess("Ticket Type '$($TicketType.name)'", 'Update')) {
                New-HaloPOSTRequest -Object $TicketType -Endpoint 'tickettype' -Update
            }
        } else {
            Throw 'Ticket Type not found in Halo to update.'
        }
    } catch {
        New-HaloError -ErrorRecord $_
    }
}