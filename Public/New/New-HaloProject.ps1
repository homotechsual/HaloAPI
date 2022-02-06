Function New-HaloProject {
    <#
        .SYNOPSIS
            Creates a project via the Halo API.
        .DESCRIPTION
            Function to send a project creation request to the Halo API
        .OUTPUTS
            Outputs an object containing the response from the web request.
    #>
    [CmdletBinding( SupportsShouldProcess = $True )]
    [OutputType([Object])]
    Param (
        # Object containing properties and values used to create a new project.
        [Parameter( Mandatory = $True )]
        [Object]$Project
    )
    Invoke-HaloPreFlightCheck
    try {
        if ($PSCmdlet.ShouldProcess("Project '$($Project.summary)'", 'Create')) {
            New-HaloPOSTRequest -Object $Project -Endpoint 'projects'
        }
    } catch {
        New-HaloError -ErrorRecord $_
    }
}