Function New-HaloTeam {
    <#
        .SYNOPSIS
            Creates a team via the Halo API.
        .DESCRIPTION
            Function to send a team creation request to the Halo API
        .OUTPUTS
            Outputs an object containing the response from the web request.
    #>
    [CmdletBinding( SupportsShouldProcess = $True )]
    [OutputType([Object])]
    Param (
        # Object containing properties and values used to create a new team.
        [Parameter( Mandatory = $True )]
        [Object]$Team
    )
    Invoke-HaloPreFlightCheck
    try {
        if ($PSCmdlet.ShouldProcess("Team '$($Team.name)'", 'Create')) {
            New-HaloPOSTRequest -Object $Team -Endpoint 'team'
        }
    } catch {
        New-HaloError -ErrorRecord $_
    }
}