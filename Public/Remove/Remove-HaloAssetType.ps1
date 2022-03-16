function Remove-HaloAssetType {
    <#
        .SYNOPSIS
           Removes an Asset Type from the Halo API.
        .DESCRIPTION
            Deletes a specific Asset Type from Halo.
        .OUTPUTS
            A powershell object containing the response.
    #>
    [cmdletbinding( SupportsShouldProcess = $True, ConfirmImpact = 'High' )]
    [OutputType([Object])]
    Param(
        # The AssetType ID
        [Parameter( Mandatory = $True )]
        [int64]$AssetTypeID
    )
    Invoke-HaloPreFlightCheck
    try {
        $ObjectToDelete = Get-HaloAssetType -AssetTypeID $AssetTypeID
        if ($ObjectToDelete) {
            if ($PSCmdlet.ShouldProcess("Asset Type '$($ObjectToDelete.name)')'", 'Delete')) {
                $Resource = "api/assettype/$($AssetTypeID)"
                $AssetTypeResult = New-HaloDELETERequest -Resource $Resource
                Return $AssetTypeResult
            }
        } else {
            Throw 'Asset Type was not found in Halo to delete.'
        }
    } catch {
        New-HaloError -ErrorRecord $_
    }
}
