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
        # Object containing properties and values used to update an existing client.
        [Parameter( Mandatory = $True )]
        [PSCustomObject]$Client
    )
    Invoke-HaloUpdate -Object $Client -Endpoint "client" -Update
}