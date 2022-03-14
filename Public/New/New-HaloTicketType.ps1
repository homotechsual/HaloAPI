Function New-HaloTicketType {
    <#
        .SYNOPSIS
            Creates one or more ticket types via the Halo API.
        .DESCRIPTION
            Function to send a ticket type creation request to the Halo API
        .OUTPUTS
            Outputs an object containing the response from the web request.
    #>
    [CmdletBinding( SupportsShouldProcess = $True )]
    [OutputType([Object[]])]
    Param (
        # Object or array of objects containing properties and values used to create one or more new ticket types.
        [Parameter( Mandatory = $True )]
        [Object[]]$TicketType
    )
    Invoke-HaloPreFlightCheck
    try {
        if ($PSCmdlet.ShouldProcess($TicketType -is [Array] ? 'Ticket Types' : 'Ticket Type', 'Create')) {
            New-HaloPOSTRequest -Object $TicketType -Endpoint 'tickettype'
        }
    } catch {
        New-HaloError -ErrorRecord $_
    }
}