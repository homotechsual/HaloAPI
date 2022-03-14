Function New-HaloAsset {
    <#
        .SYNOPSIS
            Creates one or more assets via the Halo API.
        .DESCRIPTION
            Function to send an asset creation request to the Halo API
        .OUTPUTS
            Outputs an object containing the response from the web request.
    #>
    [CmdletBinding( SupportsShouldProcess = $True )]
    [OutputType([Object[]])]
    Param (
        # Object or array of objects containing properties and values used to create one or more new assets.
        [Parameter( Mandatory = $True )]
        [Object[]]$Asset
    )
    Invoke-HaloPreFlightCheck
    try {
        if ($PSCmdlet.ShouldProcess($Asset -is [Array] ? 'Assets' : 'Asset', 'Create')) {
            New-HaloPOSTRequest -Object $Asset -Endpoint 'asset'
        }
    } catch {
        New-HaloError -ErrorRecord $_
    }
}