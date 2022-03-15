Function Set-HaloSite {
    <#
        .SYNOPSIS
            Updates one or more sites via the Halo API.
        .DESCRIPTION
            Function to send a site update request to the Halo API
        .OUTPUTS
            Outputs an object containing the response from the web request.
    #>
    [CmdletBinding( SupportsShouldProcess = $True )]
    [OutputType([Object[]])]
    Param (
        # Object or array of objects containing properties and values used to update one or more existing sites.
        [Parameter( Mandatory = $True, ValueFromPipeline )]
        [Object[]]$Site
    )
    Invoke-HaloPreFlightCheck
    try {
        $ObjectToUpdate = $Site | ForEach-Object {
            $HaloSiteParams = @{
                SiteId = $_.id
            }
            $SiteExists = Get-HaloSite @HaloSiteParams
            if ($SiteExists) {
                Return $True
            } else {
                Return $False
            }
        }
        if ($False -notin $ObjectToUpdate) {
            if ($PSCmdlet.ShouldProcess($Site -is [Array] ? 'Sites' : 'Site', 'Update')) {
                New-HaloPOSTRequest -Object $Site -Endpoint 'site' -Update
            }
        } else {
            Throw 'One or more sites was not found in Halo to update.'
        }
    } catch {
        New-HaloError -ErrorRecord $_
    }
}