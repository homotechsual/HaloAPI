Function Set-HaloProject {
    <#
        .SYNOPSIS
            Updates one or more projects via the Halo API.
        .DESCRIPTION
            Function to send a project creation update to the Halo API
        .OUTPUTS
            Outputs an object containing the response from the web request.
    #>
    [CmdletBinding( SupportsShouldProcess = $True )]
    [OutputType([Object[]])]
    Param (
        # Object or array of objects containing properties and values used to update one or more existing projects.
        [Parameter( Mandatory = $True, ValueFromPipeline )]
        [Object[]]$Project
    )
    Invoke-HaloPreFlightCheck
    try {
        $ObjectToUpdate = $False
        ForEach-Object -InputObject $Project {
            $HaloProjectParams = @{
                ProjectId = $_.id
            }
            $ProjectExists = Get-HaloProject @HaloProjectParams
            if ($ProjectExists) {
                Set-Variable -Scope 1 -Name 'ObjectToUpdate' -Value $True
            }
        }
        if ($ObjectToUpdate) {
            if ($PSCmdlet.ShouldProcess($Project -is [Array] ? 'Projects' : 'Project', 'Update')) {
                New-HaloPOSTRequest -Object $Project -Endpoint 'projects' -Update
            }
        } else {
            Throw 'One or more projects was not found in Halo to update.'
        }
    } catch {
        New-HaloError -ErrorRecord $_
    }
}