Function New-HaloTicketType {
    <#
    .SYNOPSIS
        Creates a TicketType via the Halo API.
    .DESCRIPTION
        Function to send a TicketType creation request to the Halo API
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