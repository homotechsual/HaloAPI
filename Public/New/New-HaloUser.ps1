Function New-HaloUser {
    <#
        .SYNOPSIS
            Creates one or more user via the Halo API.
        .DESCRIPTION
            Function to send a user creation request to the Halo API
        .OUTPUTS
            Outputs an object containing the response from the web request.
    #>
    [CmdletBinding( SupportsShouldProcess = $True )]
    [OutputType([Object[]])]
    Param (
        # Object or array of objects containing properties and values used to create one or more new users.
        [Parameter( Mandatory = $True )]
        [Object[]]$User
    )
    Invoke-HaloPreFlightCheck
    try {
        if ($PSCmdlet.ShouldProcess($User -is [Array] ? 'Users' : 'User', 'Create')) {
            New-HaloPOSTRequest -Object $User -Endpoint 'users'
        }
    } catch {
        New-HaloError -ErrorRecord $_
    }
}