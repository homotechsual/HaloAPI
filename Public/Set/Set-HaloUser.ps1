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
    Invoke-HaloPreFlightChecks
    $CommandName = $MyInvocation.InvocationName
    try {
        $ObjectToUpdate = Get-HaloUser -UserID $User.id
        if ($ObjectToUpdate) {
            if ($PSCmdlet.ShouldProcess('Users', 'Update')) {
                New-HaloPOSTRequest -Object $User -Endpoint 'users' -Update
            }
        } else {
            Throw 'User was not found in Halo to update.'
        }
    } catch {
        $Command = $CommandName -Replace '-', ''
        $ErrorRecord = @{
            ExceptionType = 'System.Exception'
            ErrorMessage = "$($CommandName) failed."
            InnerException = $_.Exception
            ErrorID = "Halo$($Command)CommandFailed"
            ErrorCategory = 'ReadError'
            TargetObject = $_.TargetObject
            ErrorDetails = $_.ErrorDetails
            BubbleUpDetails = $False
        }
        $CommandError = New-HaloErrorRecord @ErrorRecord
        $PSCmdlet.ThrowTerminatingError($CommandError)
    }
}