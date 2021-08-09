Function New-HaloAsset {
    <#
    .SYNOPSIS
        Creates an asset via the Halo API.
    .DESCRIPTION
        Function to send an asset creation request to the Halo API
    .OUTPUTS
        Outputs an object containing the response from the web request.
    #>
    [CmdletBinding()]
    Param (
        [Parameter( Mandatory = $True )]
        [PSCustomObject]$Asset
    )
    Invoke-HaloUpdate -Object $Asset -Endpoint "Asset"
}