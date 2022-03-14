Function New-HaloTeam {
    <#
        .SYNOPSIS
            Creates one or more teams via the Halo API.
        .DESCRIPTION
            Function to send a team creation request to the Halo API
        .OUTPUTS
            Outputs an object containing the response from the web request.
    #>
    [CmdletBinding( SupportsShouldProcess = $True )]
    [OutputType([Object[]])]
    Param (
        # Object or array of objects containing properties and values used to create one or more new teams.
        [Parameter( Mandatory = $True )]
        [Object[]]$Team
    )
    Invoke-HaloPreFlightCheck
    try {
        if ($PSCmdlet.ShouldProcess($Team -is [Array] ? 'Teams' : 'Team', 'Create')) {
            New-HaloPOSTRequest -Object $Team -Endpoint 'team'
        }
    } catch {
        New-HaloError -ErrorRecord $_
    }
}