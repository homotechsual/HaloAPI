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
        [Object[]]$Asset,
        # Skip validation checks.
        [Parameter()]
        [Switch]$SkipValidation
    )
    Invoke-HaloPreFlightCheck
    try {
        $ObjectToUpdate = $Asset | ForEach-Object {
            if ($null -eq $_.id) {
                throw 'Asset ID is required.'
            }
            $HaloAssetParams = @{
                AssetId = ($_.id)
            }
            if (-not $SkipValidation) {
                $AssetExists = Get-HaloAsset @HaloAssetParams
                if ($AssetExists) {
                    Return $True
                } else {
                    Return $False
                }
            } else {
                Write-Verbose 'Skipping validation checks.'
                Return $True
            }
        }
        if ($False -notin $ObjectToUpdate) {
            if ($PSCmdlet.ShouldProcess($Asset -is [Array] ? 'Assets' : 'Asset', 'Update')) {
                New-HaloPOSTRequest -Object $Asset -Endpoint 'asset'
            }
        } else {
            Throw 'One or more assets was not found in Halo to update.'
        }
    } catch {
        New-HaloError -ErrorRecord $_
    }
}