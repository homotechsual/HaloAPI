Function Set-HaloUser {
    <#
    .SYNOPSIS
        Updates a user via the Halo API.
    .DESCRIPTION
        Function to send a user update request to the Halo API
    .OUTPUTS
        Outputs an object containing the response from the web request.
    #>
    [CmdletBinding()]
    Param (
        [Parameter( Mandatory = $True )]
        [PSCustomObject]$User
    )
    Invoke-HaloUpdate -Object $User -Endpoint "users" -Update
}