Function Set-HaloAsset {
    <#
        .SYNOPSIS
            Updates an asset via the Halo API.
        .DESCRIPTION
            Function to send an asset update request to the Halo API
        .OUTPUTS
            Outputs an object containing the response from the web request.
    #>
    [CmdletBinding( SupportsShouldProcess = $True )]
    [OutputType([Object])]
    Param (
        # Object containing properties and values used to update an existing asset.
        [Parameter( Mandatory = $True )]
        [Object]$Asset
    )
    try {
        $ObjectToUpdate = Get-HaloAsset -AssetID $Asset.id
        if ($ObjectToUpdate) {
            if ($PSCmdlet.ShouldProcess("Asset '$($ObjectToUpdate.inventory_name)'", "Update")) {
                New-HaloPOSTRequest -Object $Asset -Endpoint "asset" -Update
            }
        } else {
            Throw "Asset was not found in Halo to update."
        }
    } catch {
        Write-Error "Failed to update agent with the Halo API. You'll see more detail if using '-Verbose'"
        Write-Verbose "$_"
    }
}