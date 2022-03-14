Function Set-HaloTeam {
    <#
        .SYNOPSIS
            Updates one or more teams via the Halo API.
        .DESCRIPTION
            Function to send a team update request to the Halo API
        .OUTPUTS
            Outputs an object containing the response from the web request.
    #>
    [CmdletBinding( SupportsShouldProcess = $True )]
    [OutputType([Object[]])]
    Param (
        # Object or array of objects containing properties and values used to update one or more existing teams.
        [Parameter( Mandatory = $True, ValueFromPipeline )]
        [Object[]]$Team
    )
    Invoke-HaloPreFlightCheck
    try {
        $ObjectToUpdate = $False
        ForEach-Object -InputObject $Team {
            $HaloTeamParams = @{
                TeamId = $_.id
            }
            $TeamExists = Get-HaloTeam @HaloTeamParams
            if ($TeamExists) {
                Set-Variable -Scope 1 -Name 'ObjectToUpdate' -Value $True
            }
        }
        if ($ObjectToUpdate) {
            if ($PSCmdlet.ShouldProcess($Team -is [Array] ? 'Teams' : 'Team', 'Update')) {
                New-HaloPOSTRequest -Object $Team -Endpoint 'team' -Update
            }
        } else {
            Throw 'One or more teams was not found in Halo to update.'
        }
    } catch {
        New-HaloError -ErrorRecord $_
    }
}