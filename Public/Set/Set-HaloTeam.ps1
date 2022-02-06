Function Set-HaloTeam {
    <#
        .SYNOPSIS
            Updates a team via the Halo API.
        .DESCRIPTION
            Function to send a team update request to the Halo API
        .OUTPUTS
            Outputs an object containing the response from the web request.
    #>
    [CmdletBinding( SupportsShouldProcess = $True )]
    [OutputType([Object])]
    Param (
        # Object containing properties and values used to update an existing team.
        [Parameter( Mandatory = $True, ValueFromPipeline )]
        [Object]$Team
    )
    Invoke-HaloPreFlightCheck
    try {
        $ObjectToUpdate = Get-HaloTeam -TeamID $Team.id
        if ($ObjectToUpdate) {
            if ($PSCmdlet.ShouldProcess("Team '$($ObjectToUpdate.name)'", 'Update')) {
                New-HaloPOSTRequest -Object $Team -Endpoint 'team' -Update
            }
        } else {
            Throw 'Team was not found in Halo to update.'
        }
    } catch {
        New-HaloError -ErrorRecord $_
    }
}