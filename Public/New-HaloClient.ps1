Function New-HaloClient {
    <#
    .SYNOPSIS
        Creates a client via the Halo API.
    .DESCRIPTION
        Function to send a client creation request to the Halo API
    .OUTPUTS
        Outputs an object containing the response from the web request.
    #>
    [CmdletBinding()]
    Param (
        [Parameter( Mandatory = $True )]
        [PSCustomObject]$Client
    )
    Invoke-HaloUpdate -Object $Client -Endpoint "Client"
}