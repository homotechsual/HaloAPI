Function Set-HaloUser {
    <#
        .SYNOPSIS
            Updates a user via the Halo API.
        .DESCRIPTION
            Function to send a user update request to the Halo API
        .OUTPUTS
            Outputs an object containing the response from the web request.
    #>
    [CmdletBinding( SupportsShouldProcess = $True )]
    [OutputType([PSCustomObject])]
    Param (
        # Object containing properties and values used to update an existing user.
        [Parameter( Mandatory = $True )]
        [PSCustomObject]$User
    )
    if ($PSCmdlet.ShouldProcess("Users", "Update")) {
        Invoke-HaloUpdate -Object $User -Endpoint "users" -Update
    }
}