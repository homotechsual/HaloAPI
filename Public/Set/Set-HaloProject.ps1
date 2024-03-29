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
        [Object[]]$Project,
        # Skip validation checks.
        [Parameter()]
        [Switch]$SkipValidation
    )
    Invoke-HaloPreFlightCheck
    try {
        $ObjectToUpdate = $Project | ForEach-Object {
            if ($null -eq $_.id) {
                throw 'Project ID is required.'
            }
            $HaloProjectParams = @{
                ProjectId = $_.id
            }
            if (-not $SkipValidation) {
                $ProjectExists = Get-HaloProject @HaloProjectParams
                if ($ProjectExists) {
                    Return $True
                } else {
                    Return $False
                }
            } else {
                Write-Verbose 'Skipping validation checks.'
                Return $True
            }
        }
        if ($False -notin $ObjectToUpdate) {
            if ($PSCmdlet.ShouldProcess($Project -is [Array] ? 'Projects' : 'Project', 'Update')) {
                New-HaloPOSTRequest -Object $Project -Endpoint 'projects'
            }
        } else {
            Throw 'One or more projects was not found in Halo to update.'
        }
    } catch {
        New-HaloError -ErrorRecord $_
    }
}