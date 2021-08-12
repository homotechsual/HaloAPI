Function New-HaloAsset {
    <#
        .SYNOPSIS
            Creates an asset via the Halo API.
        .DESCRIPTION
            Function to send an asset creation request to the Halo API
        .OUTPUTS
            Outputs an object containing the response from the web request.
    #>
    [CmdletBinding( SupportsShouldProcess = $True )]
    [OutputType([Object])]
    Param (
        # Object containing properties and values used to create a new asset.
        [Parameter( Mandatory = $True )]
        [Object]$Asset
    )
    try {
        if ($PSCmdlet.ShouldProcess("Asset $($Asset.inventory_number)", "Create")) {
            New-HaloPOSTRequest -Object $Asset -Endpoint "asset"
        }
    } catch {
        Write-Error "Failed to create asset with the Halo API. You'll see more detail if using '-Verbose'"
        Write-Verbose "$_"
    }
}