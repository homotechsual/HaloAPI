Function New-HaloTicketType {
    <#
        .SYNOPSIS
            Creates a ticket type via the Halo API.
        .DESCRIPTION
            Function to send a ticket type creation request to the Halo API
        .OUTPUTS
            Outputs an object containing the response from the web request.
    #>
    [CmdletBinding( SupportsShouldProcess = $True )]
    [OutputType([Object])]
    Param (
        # Object containing properties and values used to create a new ticket type.
        [Parameter( Mandatory = $True )]
        [Object]$TicketType
    )
    Invoke-HaloPreFlightCheck
    try {
        if ($PSCmdlet.ShouldProcess("Ticket Type '$($TicketType.name)'", 'Create')) {
            New-HaloPOSTRequest -Object $TicketType -Endpoint 'tickettype'
        }
    } catch {
        New-HaloError -ErrorRecord $_
    }
}