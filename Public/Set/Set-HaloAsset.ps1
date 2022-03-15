Function Set-HaloAsset {
    <#
        .SYNOPSIS
            Updates one or more assets via the Halo API.
        .DESCRIPTION
            Function to send an asset update request to the Halo API
        .OUTPUTS
            Outputs an object containing the response from the web request.
    #>
    [CmdletBinding( SupportsShouldProcess = $True )]
    [OutputType([Object])]
    Param (
        # Object or array of objects containing properties and values used to update one or more existing assets.
        [Parameter( Mandatory = $True, ValueFromPipeline )]
        [Object[]]$Asset
    )
    Invoke-HaloPreFlightCheck
    try {
        $ObjectToUpdate = ForEach-Object -InputObject $Asset {
            $HaloAssetParams = @{
                AssetId = ($_.id)
            }
            $AssetExists = Get-HaloAsset @HaloAssetParams
            if ($AssetExists) {
                Return $True
            } else {
                Return $False
            }
        }
        if ($False -notin $ObjectToUpdate) {
            if ($PSCmdlet.ShouldProcess($Asset -is [Array] ? 'Assets' : 'Asset', 'Update')) {
                New-HaloPOSTRequest -Object $Asset -Endpoint 'asset' -Update
            }
        } else {
            Throw 'One or more assets was not found in Halo to update.'
        }
    } catch {
        New-HaloError -ErrorRecord $_
    }
}