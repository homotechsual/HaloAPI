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
    [OutputType([PSCustomObject])]
    Param (
        # Object containing properties and values used to update an existing team.
        [Parameter( Mandatory = $True )]
        [PSCustomObject]$Team
    )
    if ($PSCmdlet.ShouldProcess("Team", "Update")) {
        Invoke-HaloUpdate -Object $Team -Endpoint "team" -Update
    }
}