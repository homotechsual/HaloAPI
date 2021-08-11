Function New-HaloUser {
    <#
        .SYNOPSIS
            Creates a user via the Halo API.
        .DESCRIPTION
            Function to send a user creation request to the Halo API
        .OUTPUTS
            Outputs an object containing the response from the web request.
    #>
    [CmdletBinding( SupportsShouldProcess = $True )]
    [OutputType([PSCustomObject])]
    Param (
        # Object containing properties and values used to create a new user.
        [Parameter( Mandatory = $True )]
        [PSCustomObject]$User
    )
    if ($PSCmdlet.ShouldProcess("User", "Create")) {
        Invoke-HaloUpdate -Object $User -Endpoint "users"
    }
}