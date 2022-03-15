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
        [Object[]]$Ticket
    )
    Invoke-HaloPreFlightCheck
    try {
        if ($PSCmdlet.ShouldProcess($Ticket -is [Array] ? 'Tickets' : 'Ticket', 'Create')) {
            New-HaloPOSTRequest -Object $Ticket -Endpoint 'tickets'
        }
    } catch {
        New-HaloError -ErrorRecord $_
    }
}