Function New-HaloContract {
    <#
    .SYNOPSIS
        Updates an Contract via the Halo API.
    .DESCRIPTION
        Function to send an Contract update request to the Halo API
    .OUTPUTS
        Outputs an object containing the response from the web request.
    #>
    [CmdletBinding()]
    Param (
        [Parameter( Mandatory = $True )]
        [PSCustomObject]$Contract
    )
    Invoke-HaloUpdate -Object $Contract -Endpoint "ClientContract" -update
}