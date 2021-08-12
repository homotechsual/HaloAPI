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
    [OutputType([Object])]
    Param (
        # Object containing properties and values used to create a new ticket.
        [Parameter( Mandatory = $True )]
        [Object]$Ticket
    )
    try {
        if ($PSCmdlet.ShouldProcess("Ticket '$($Ticket.summary)'", "Create")) {
            New-HaloPOSTRequest -Object $Ticket -Endpoint "tickets"
        }
    } catch {
        Write-Error "Failed to create ticket with the Halo API. You'll see more detail if using '-Verbose'"
        Write-Verbose "$_"
    }
}