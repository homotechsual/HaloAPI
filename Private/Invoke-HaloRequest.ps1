#Requires -Version 7

function Invoke-HaloRequest {
    <#
        .SYNOPSIS
            Sends a request to the Halo API.
        .DESCRIPTION
            Wrapper function to send web requests to the Halo API.
        .OUTPUTS
            Outputs an object containing the response from the web request.
    #>
    [Cmdletbinding()]
    [OutputType([Object])]
    param (
        # Hashtable containing the web request parameters.
        [Hashtable]$WebRequestParams,
        # Returns the Raw result. Useful for file downloads.
        [Switch]$RawResult
    )
    $ProgressPreference = 'SilentlyContinue'
    Invoke-HaloPreFlightCheck
    $Now = Get-Date
    if ($Script:HAPIAuthToken.Expires -le $Now) {
        Write-Verbose 'The auth token has expired, renewing.'
        $ReconnectParameters = @{
            URL = $Script:HAPIConnectionInformation.URL
            ClientId = $Script:HAPIConnectionInformation.ClientID
            ClientSecret = $Script:HAPIConnectionInformation.ClientSecret
            Scopes = $Script:HAPIConnectionInformation.AuthScopes
            Tenant = $Script:HAPIConnectionInformation.Tenant
        }
        Connect-HaloAPI @ReconnectParameters
    }
    if ($null -ne $Script:HAPIAuthToken) {
        $AuthHeaders = @{
            Authorization = "$($Script:HAPIAuthToken.Type) $($Script:HAPIAuthToken.Access)"
        }
    } else {
        $AuthHeaders = $null
    }
    try {
        Write-Verbose "Making a $($WebRequestParams.Method) request to $($WebRequestParams.Uri)"
        $Response = Invoke-WebRequest @WebRequestParams -Headers $AuthHeaders -ContentType 'application/json'
        Write-Debug "Response headers: $($Response.Headers | Out-String)"
        if ($RawResult) {
            $Results = $Response
        } else {
            $Results = $Response.Content | ConvertFrom-Json
        }
        return $Results
    } catch {
        $ErrorRecord = @{
            ExceptionType = 'System.Net.Http.HttpRequestException'
            ErrorMessage = "Halo API request $($_.TargetObject.Method) $($_.TargetObject.RequestUri) failed."
            InnerException = $_.Exception
            ErrorID = 'HaloAPIRequestFailed'
            ErrorCategory = 'ProtocolError'
            TargetObject = $_.TargetObject
            ErrorDetails = $_.ErrorDetails
            BubbleUpDetails = $True
        }
        $RequestError = New-HaloErrorRecord @ErrorRecord
        $PSCmdlet.ThrowTerminatingError($RequestError)
    }
}
