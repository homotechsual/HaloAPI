Function New-HaloTeam {
    <#
    .SYNOPSIS
        Creates a team via the Halo API.
    .DESCRIPTION
        Function to send a team creation request to the Halo API
    .OUTPUTS
        Outputs an object containing the response from the web request.
    #>
    [CmdletBinding()]
    Param (
        [Parameter( Mandatory = $True )]
        [PSCustomObject]$Team
    )
    Invoke-HaloUpdate -Object $Team -Endpoint "Team"
}