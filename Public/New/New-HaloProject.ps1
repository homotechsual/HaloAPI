Function New-HaloProject {
    <#
        .SYNOPSIS
            Creates one or more projects via the Halo API.
        .DESCRIPTION
            Function to send a project creation request to the Halo API
        .OUTPUTS
            Outputs an object containing the response from the web request.
    #>
    [CmdletBinding( SupportsShouldProcess = $True )]
    [OutputType([Object[]])]
    Param (
        # Object or array of objects containing properties and values used to create one or more new projects.
        [Parameter( Mandatory = $True )]
        [Object[]]$Project
    )
    Invoke-HaloPreFlightCheck
    try {
        if ($PSCmdlet.ShouldProcess($Project -is [Array] ? 'Projects' : 'Project', 'Create')) {
            New-HaloPOSTRequest -Object $Project -Endpoint 'projects'
        }
    } catch {
        New-HaloError -ErrorRecord $_
    }
}