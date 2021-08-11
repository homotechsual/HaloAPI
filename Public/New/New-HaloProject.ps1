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
    [OutputType([PSCustomObject])]
    Param (
        # Object containing properties and values used to create a new project.
        [Parameter( Mandatory = $True )]
        [PSCustomObject]$Project
    )
    if ($PSCmdlet.ShouldProcess("Project", "Create")) {
        Invoke-HaloUpdate -Object $Project -Endpoint "projects"
    }
}