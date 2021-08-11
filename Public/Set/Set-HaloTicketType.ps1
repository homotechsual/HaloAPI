Function Set-HaloTicketType {
    <#
    .SYNOPSIS
        Updates a ticket type via the Halo API.
    .DESCRIPTION
        Function to send a ticket type update request to the Halo API
    .OUTPUTS
        Outputs an object containing the response from the web request.
    #>
    [CmdletBinding()]
    Param (
        # Object containing properties and values used to update an existing ticket type.
        [Parameter( Mandatory = $True )]
        [PSCustomObject]$TicketType
    )
    Invoke-HaloUpdate -Object $TicketType -Endpoint "tickettype" -Update
}