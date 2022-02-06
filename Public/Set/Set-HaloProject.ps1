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
    [OutputType([Object])]
    Param (
        # Object containing properties and values used to update an existing project.
        [Parameter( Mandatory = $True, ValueFromPipeline )]
        [Object]$Project
    )
    Invoke-HaloPreFlightCheck
    try {
        $ObjectToUpdate = Get-HaloProject -ProjectID $Project.id
        if ($ObjectToUpdate) {
            if ($PSCmdlet.ShouldProcess("Project '$($ObjectToUpdate.summary)'", 'Update')) {
                New-HaloPOSTRequest -Object $Project -Endpoint 'projects' -Update
            }
        } else {
            Throw 'Project was not found in Halo to update.'
        }
    } catch {
        New-HaloError -ErrorRecord $_
    }
}