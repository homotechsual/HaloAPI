Function Set-HaloAssetType {
    <#
        .SYNOPSIS
            Updates an asset type via the Halo API.
        .DESCRIPTION
            Function to send an asset type update request to the Halo API
        .OUTPUTS
            Outputs an object containing the response from the web request.
    #>
    [CmdletBinding( SupportsShouldProcess = $True )]
    [OutputType([Object])]
    Param (
        # Object containing properties and values used to update an existing asset type.
        [Parameter( Mandatory = $True, ValueFromPipeline )]
        [Object]$AssetType
    )
    Invoke-HaloPreFlightCheck
    try {
        if ($null -eq $AssetType.id) {
            throw 'Asset type ID is required.'
        }
        $ObjectToUpdate = Get-HaloAssetType -AssetTypeID $AssetType.id
        if ($ObjectToUpdate) {
            if ($PSCmdlet.ShouldProcess("Asset Type '$($ObjectToUpdate.name)'", 'Update')) {
                New-HaloPOSTRequest -Object $AssetType -Endpoint 'assettype' -Update
            }
        } else {
            Throw 'Asset Type was not found in Halo to update.'
        }
    } catch {
        New-HaloError -ErrorRecord $_
    }
}
