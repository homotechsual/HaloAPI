#Requires -Version 7
function Invoke-HaloAuthorisationCodeRefresh {
    <#
    .SYNOPSIS
        Renews the auth token for a session connected with Connect-HaloAPI -Interactive.
    .DESCRIPTION
        Uses the stored refresh token to get a new access token. If there is no refresh token, or the refresh is rejected, falls back to signing in through the browser again. Updates $Script:HAPIAuthToken.
    .OUTPUTS
        None. The script-scoped auth token is updated in place.
    #>
    [CmdletBinding()]
    [OutputType([System.Void])]
    param ()
    $TokenPayload = $null
    if ($Script:HAPIAuthToken.Refresh) {
        Write-Verbose 'Refreshing the Halo auth token using the refresh token.'
        $RefreshRequestParams = @{
            Uri = $Script:HAPIConnectionInformation.AuthURI
            Method = 'POST'
            Body = @{
                grant_type = 'refresh_token'
                client_id = $Script:HAPIConnectionInformation.ClientID
                refresh_token = $Script:HAPIAuthToken.Refresh
            }
            ContentType = 'application/x-www-form-urlencoded'
            Headers = $Script:HAPIConnectionInformation.AdditionalHeaders
        }
        try {
            $RefreshResponse = Invoke-WebRequest @RefreshRequestParams
            $TokenPayload = ConvertFrom-Json -InputObject $RefreshResponse.Content
        } catch {
            Write-Warning ('Could not refresh the Halo auth token, signing in again. {0}' -f $_.Exception.Message)
        }
    }
    $PreviousRefresh = $Script:HAPIAuthToken.Refresh
    if (-not $TokenPayload.access_token) {
        $PreviousRefresh = $null
        $TokenPayload = Invoke-HaloAuthorisationCodeFlow -ConnectionInformation $Script:HAPIConnectionInformation
    }
    $AuthToken = ConvertTo-HaloAuthToken -TokenPayload $TokenPayload
    # Some servers do not rotate refresh tokens, keep the existing one if none is returned.
    if (-not $AuthToken.Refresh) {
        $AuthToken.Refresh = $PreviousRefresh
    }
    Set-Variable -Name 'HAPIAuthToken' -Value $AuthToken -Visibility Private -Scope Script -Force
    Write-Verbose 'Renewed the Halo auth token.'
}
