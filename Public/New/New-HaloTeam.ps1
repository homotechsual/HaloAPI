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
    [OutputType([PSCustomObject])]
    Param (
        # Object containing properties and values used to create a new team.
        [Parameter( Mandatory = $True )]
        [PSCustomObject]$Team
    )
    if ($PSCmdlet.ShouldProcess("Team", "Create")) {
        Invoke-HaloUpdate -Object $Team -Endpoint "team"
    }
}