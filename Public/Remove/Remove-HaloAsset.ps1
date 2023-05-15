function Remove-HaloAsset {
    <#
        .SYNOPSIS
           Removes an Asset from the Halo API.
        .DESCRIPTION
            Deletes a specific Asset from Halo.
        .OUTPUTS
            A powershell object containing the response.
    #>
    [cmdletbinding( SupportsShouldProcess = $True, ConfirmImpact = 'High' )]
    [OutputType([Object])]
    Param(
        # The Asset ID
        [Parameter( Mandatory, ParameterSetName = 'Single' )]
        [int64]$AssetID,
        # Object containing Asset id and ticket id for batch processing.
        [Parameter( Mandatory, ParameterSetName = 'Batch')]
        [Object]$Asset
    )
    Invoke-HaloPreFlightCheck
    try {
        if ($Asset) {
            $AssetID = $Asset.Id
        }
        $ObjectToDelete = Get-HaloAsset -AssetID $AssetID
        if ($ObjectToDelete) {
            if ($PSCmdlet.ShouldProcess("Asset '$($ObjectToDelete.id)' by '$($ObjectToDelete.who)'", 'Delete')) {
                $Resource = "api/Asset/$($AssetID)"
                $AssetResults = New-HaloDELETERequest -Resource $Resource
                Return $AssetResults
            }
        } else {
            Throw 'Asset was not found in Halo to delete.'
        }
    } catch {
        New-HaloError -ErrorRecord $_
    }
}