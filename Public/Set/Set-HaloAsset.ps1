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
    [OutputType([PSCustomObject])]
    Param (
        # Object containing properties and values used to update an existing asset.
        [Parameter( Mandatory = $True )]
        [PSCustomObject]$Asset
    )
    if ($PSCmdlet.ShouldProcess("Asset", "Update")) {
        Invoke-HaloUpdate -Object $Asset -Endpoint "asset" -Update
    }
}