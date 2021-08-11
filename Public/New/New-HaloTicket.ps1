Function New-HaloTicket {
    <#
        .SYNOPSIS
            Creates a ticket via the Halo API.
        .DESCRIPTION
            Function to send a ticket creation request to the Halo API
        .OUTPUTS
            Outputs an object containing the response from the web request.
    #>
    [CmdletBinding( SupportsShouldProcess = $True )]
    [OutputType([PSCustomObject])]
    Param (
        # Object containing properties and values used to create a new ticket.
        [Parameter( Mandatory = $True )]
        [PSCustomObject]$Ticket
    )
    if ($PSCmdlet.ShouldProcess("Ticket", "Create")) {
        Invoke-HaloUpdate -Object $Ticket -Endpoint "tickets"
    }
}