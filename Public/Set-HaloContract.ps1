Function New-HaloContract {
    <#
    .SYNOPSIS
        Updates a contract via the Halo API.
    .DESCRIPTION
        Function to send a contract update request to the Halo API
    .OUTPUTS
        Outputs an object containing the response from the web request.
    #>
    [CmdletBinding()]
    Param (
        [Parameter( Mandatory = $True )]
        [PSCustomObject]$Contract
    )
    Invoke-HaloUpdate -Object $Contract -Endpoint "clientcontract" -Update
}