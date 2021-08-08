Function New-HaloUser {
    <#
    .SYNOPSIS
        Creates a user via the Halo API.
    .DESCRIPTION
        Function to send a user creation request to the Halo API
    .OUTPUTS
        Outputs an object containing the response from the web request.
    #>
    [CmdletBinding()]
    Param (
        [Parameter( Mandatory = $True )]
        [PSCustomObject]$User
    )
    Invoke-HaloUpdate -Object $User -Endpoint "Users"
}