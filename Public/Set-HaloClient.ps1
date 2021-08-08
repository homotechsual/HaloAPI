Function Set-HaloClient {
    <#
    .SYNOPSIS
        Updates a client via the Halo API.
    .DESCRIPTION
        Function to send a client update request to the Halo API
    .OUTPUTS
        Outputs an object containing the response from the web request.
    #> 
    [CmdletBinding()]
    Param (
        [Parameter( Mandatory = $True )]
        [PSCustomObject]$Client
    )
    Invoke-HaloUpdate -Update -Object $Client -Endpoint "Client"
}