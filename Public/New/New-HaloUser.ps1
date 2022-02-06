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
    [OutputType([Object])]
    Param (
        # Object containing properties and values used to create a new user.
        [Parameter( Mandatory = $True )]
        [Object]$User
    )
    Invoke-HaloPreFlightCheck
    try {
        if ($PSCmdlet.ShouldProcess("User '$($User.name)'", 'Create')) {
            New-HaloPOSTRequest -Object $User -Endpoint 'users'
        }
    } catch {
        New-HaloError -ErrorRecord $_
    }
}