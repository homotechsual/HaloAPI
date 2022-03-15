Function New-HaloSite {
    <#
        .SYNOPSIS
            Creates one or more sites via the Halo API.
        .DESCRIPTION
            Function to send a site creation request to the Halo API
        .OUTPUTS
            Outputs an object containing the response from the web request.
    #>
    [CmdletBinding( SupportsShouldProcess = $True )]
    [OutputType([Object[]])]
    Param (
        # Object or array of objects containing properties and values used to create one or more new sites.
        [Parameter( Mandatory = $True )]
        [Object[]]$Site
    )
    Invoke-HaloPreFlightCheck
    try {
        if ($PSCmdlet.ShouldProcess($Site -is [Array] ? 'Sites' : 'Site', 'Create')) {
            New-HaloPOSTRequest -Object $Site -Endpoint 'site'
        }
    } catch {
        New-HaloError -ErrorRecord $_
    }
}