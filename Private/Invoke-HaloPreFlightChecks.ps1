function Invoke-HaloPreFlightCheck {
    if ($null -eq $Script:HAPIConnectionInformation) {
        $ErrorRecord = @{
            ExceptionType = 'System.Security.Authentication.AuthenticationException'
            ErrorMessage = "Missing Halo connection information, please run 'Connect-HaloAPI' first."
            ErrorID = 'HaloMissingConnectionInformation'
            ErrorCategory = 'ConnectionError'
            BubbleUpDetails = $True
        }
        $ConnectionInformationError = New-HaloErrorRecord @ErrorRecord
        $PSCmdlet.ThrowTerminatingError($ConnectionInformationError)
    }
    if (($null -eq $Script:HAPIAuthToken) -and ($null -eq $AllowAnonymous)) {
        $ErrorRecord = @{
            ExceptionType = 'System.Security.Authentication.AuthenticationException'
            ErrorMessage = "Missing Halo authentication information, please run 'Connect-HaloAPI' first."
            ErrorID = 'HaloMissingAuthenticationInformation'
            ErrorCategory = 'AuthenticationError'
            BubbleUpDetails = $True
        }
        $AuthenticationInformationError = New-HaloErrorRecord @ErrorRecord
        $PSCmdlet.ThrowTerminatingError($AuthenticationInformationError)
    }
}