Function New-HaloAssetType {
    <#
        .SYNOPSIS
            Creates an asset type via the Halo API.
        .DESCRIPTION
            Function to send an asset type creation request to the Halo API
        .OUTPUTS
            Outputs an object containing the response from the web request.
    #>
    [CmdletBinding( SupportsShouldProcess = $True )]
    [OutputType([Object])]
    Param (
        # Object containing properties and values used to create a new asset.
        [Parameter( Mandatory = $True )]
        [Object]$AssetType
    )
    Invoke-HaloPreFlightCheck
    try {
        if ($PSCmdlet.ShouldProcess("AssetType $($AssetType.name)", 'Create')) {
            New-HaloPOSTRequest -Object $AssetType -Endpoint 'assettype'
        }
    } catch {
        New-HaloError -ErrorRecord $_
    }
}
