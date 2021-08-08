Function Set-HaloTicket {
    <#
    .SYNOPSIS
        Updates a Ticket via the Halo API.
    .DESCRIPTION
        Function to send a Ticket update request to the Halo API
    .OUTPUTS
        Outputs an object containing the response from the web request.
    #>
    [CmdletBinding()]
    Param (
        [Parameter( Mandatory = $True )]
        [PSCustomObject]$Ticket
    )
    Invoke-HaloUpdate -Object $Ticket -Endpoint "Tickets" -update
}