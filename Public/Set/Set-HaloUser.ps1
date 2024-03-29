Function Set-HaloUser {
    <#
        .SYNOPSIS
            Updates one or more users via the Halo API.
        .DESCRIPTION
            Function to send a user update request to the Halo API
        .OUTPUTS
            Outputs an object containing the response from the web request.
    #>
    [CmdletBinding( SupportsShouldProcess = $True )]
    [OutputType([Object[]])]
    Param (
        # Object or array of objects containing properties and values used to update one or more existing users.
        [Parameter( Mandatory = $True, ValueFromPipeline )]
        [Object[]]$User,
        # Skip validation checks.
        [Parameter()]
        [Switch]$SkipValidation
    )
    Invoke-HaloPreFlightCheck
    try {
        $ObjectToUpdate = $User | ForEach-Object {
            if ($null -eq $_.id) {
                throw 'User ID is required.'
            }
            $HaloUserParams = @{
                UserId = $_.id
            }
            if (-not $SkipValidation) {
                $UserExists = Get-HaloUser @HaloUserParams
                if ($UserExists) {
                    Return $True
                } else {
                    Return $False
                }
            } else {
                Write-Verbose 'Skipping validation checks.'
                Return $True
            }
        }
        if ($False -notin $ObjectToUpdate) {
            if ($PSCmdlet.ShouldProcess($User -is [Array] ? 'Users' : 'User', 'Update')) {
                New-HaloPOSTRequest -Object $User -Endpoint 'users'
            }
        } else {
            Throw 'One or more users was not found in Halo to update.'
        }
    } catch {
        New-HaloError -ErrorRecord $_
    }
}