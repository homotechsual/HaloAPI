Function Set-HaloTicket {
    <#
    .SYNOPSIS
        Updates a ticket via the Halo API.
    .DESCRIPTION
        Function to send a ticket update request to the Halo API
    .OUTPUTS
        Outputs an object containing the response from the web request.
    #>
    [CmdletBinding()]
    Param (
        # Object containing properties and values used to update an existing ticket.
        [Parameter( Mandatory = $True )]
        [PSCustomObject]$Ticket
    )
    Invoke-HaloUpdate -Object $Ticket -Endpoint "tickets" -Update
}