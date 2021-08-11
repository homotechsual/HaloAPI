Function Set-HaloProject {
    <#
    .SYNOPSIS
        Updates a project via the Halo API.
    .DESCRIPTION
        Function to send a project creation update to the Halo API
    .OUTPUTS
        Outputs an object containing the response from the web request.
    #>
    [CmdletBinding()]
    Param (
        # Object containing properties and values used to update an existing project.
        [Parameter( Mandatory = $True )]
        [PSCustomObject]$Project
    )
    Invoke-HaloUpdate -Object $Project -Endpoint "projects" -Update
}