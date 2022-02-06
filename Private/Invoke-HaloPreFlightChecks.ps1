using namespace System.Management.Automation

function Invoke-HaloPreFlightCheck {
    if ($null -eq $Script:HAPIConnectionInformation) {
        $NoConnectionInformationException = [System.Exception]::New("Missing Halo connection information, please run 'Connect-HaloAPI' first.")
        $ErrorRecord = [ErrorRecord]::New($NoConnectionInformationException, 'NoConnectionInformation', 'Invoke-HaloPreFlightCheck', 'HaloPreFlightCheck')
        
        New-HaloError -ErrorRecord $ErrorRecord
    }
    if (($null -eq $Script:HAPIAuthToken) -and ($null -eq $AllowAnonymous)) {
        $NoAuthTokenException = [System.Exception]::New("Missing Halo authentication token, please run 'Connect-HaloAPI' first.")
        $ErrorRecord = [ErrorRecord]::New($NoAuthTokenException, 'NoAuthToken', 'Invoke-HaloPreFlightCheck', 'HaloPreFlightCheck')

        New-HaloError -ErrorRecord $ErrorRecord
    }
}