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
    [OutputType([PSCustomObject])]
    Param (
        # Object containing properties and values used to create a new asset.
        [Parameter( Mandatory = $True )]
        [PSCustomObject]$Asset
    )
    if ($PSCmdlet.ShouldProcess("Asset", "Create")) {
        Invoke-HaloUpdate -Object $Asset -Endpoint "asset"
    }
}