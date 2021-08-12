Function New-HaloSite {
    <#
        .SYNOPSIS
            Creates a site via the Halo API.
        .DESCRIPTION
            Function to send a site creation request to the Halo API
        .OUTPUTS
            Outputs an object containing the response from the web request.
    #>
    [CmdletBinding( SupportsShouldProcess = $True )]
    [OutputType([Object])]
    Param (
        # Object containing properties and values used to create a new site.
        [Parameter( Mandatory = $True )]
        [Object]$Site
    )
    try {
        if ($PSCmdlet.ShouldProcess("Site '$($Site.name)'", "Create")) {
            New-HaloPOSTRequest -Object $Site -Endpoint "site"
        }
    } catch {
        Write-Error "Failed to create site with the Halo API. You'll see more detail if using '-Verbose'"
        Write-Verbose "$_"
    }
}