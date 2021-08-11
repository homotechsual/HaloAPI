Function Set-HaloProject {
    <#
        .SYNOPSIS
            Updates a project via the Halo API.
        .DESCRIPTION
            Function to send a project creation update to the Halo API
        .OUTPUTS
            Outputs an object containing the response from the web request.
    #>
    [CmdletBinding( SupportsShouldProcess = $True )]
    [OutputType([PSCustomObject])]
    Param (
        # Object containing properties and values used to update an existing project.
        [Parameter( Mandatory = $True )]
        [PSCustomObject]$Project
    )
    if ($PSCmdlet.ShouldProcess("Project", "Update")) {
        Invoke-HaloUpdate -Object $Project -Endpoint "projects" -Update
    }
}