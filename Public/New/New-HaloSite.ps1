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
    [OutputType([PSCustomObject])]
    Param (
        # Object containing properties and values used to create a new site.
        [Parameter( Mandatory = $True )]
        [PSCustomObject]$Site
    )
    if ($PSCmdlet.ShouldProcess("Site", "Create")) {
        Invoke-HaloUpdate -Object $Site -Endpoint "site"
    }
}