Function Set-HaloTeam {
    <#
    .SYNOPSIS
        Updates a Team via the Halo API.
    .DESCRIPTION
        Function to send a Team update request to the Halo API
    .OUTPUTS
        Outputs an object containing the response from the web request.
    #>
    [CmdletBinding()]
    Param (
        [Parameter( Mandatory = $True )]
        [PSCustomObject]$Team
    )
    Invoke-HaloUpdate -Object $Team -Endpoint "Team" -update
}