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
    [OutputType([PSCustomObject])]
    Param (
        # Object containing properties and values used to create a new ticket type.
        [Parameter( Mandatory = $True )]
        [PSCustomObject]$TicketType
    )
    if ($PSCmdlet.ShouldProcess("Ticket Type", "Create")) {
        Invoke-HaloUpdate -Object $TicketType -Endpoint "tickettype"
    }
}