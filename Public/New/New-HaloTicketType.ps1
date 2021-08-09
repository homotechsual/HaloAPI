Function New-HaloTicketType {
    <#
    .SYNOPSIS
        Creates a ticket type via the Halo API.
    .DESCRIPTION
        Function to send a ticket type creation request to the Halo API
    .OUTPUTS
        Outputs an object containing the response from the web request.
    #>
    [CmdletBinding()]
    Param (
        [Parameter( Mandatory = $True )]
        [PSCustomObject]$TicketType
    )
    Invoke-HaloUpdate -Object $TicketType -Endpoint "TicketType"
}