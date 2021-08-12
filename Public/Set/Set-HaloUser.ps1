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
    [OutputType([Object])]
    Param (
        # Object containing properties and values used to update an existing user.
        [Parameter( Mandatory = $True )]
        [Object]$User
    )
    try {
        $ObjectToUpdate = Get-HaloUser -UserID $User.id
        if ($ObjectToUpdate) {
            if ($PSCmdlet.ShouldProcess("Users", "Update")) {
                New-HaloPOSTRequest -Object $User -Endpoint "users" -Update
            }
        } else {
            Throw "User was not found in Halo to update."
        }
    } catch {
        Write-Error "Failed to update user with the Halo API. You'll see more detail if using '-Verbose'"
        Write-Verbose "$_"
    }
}