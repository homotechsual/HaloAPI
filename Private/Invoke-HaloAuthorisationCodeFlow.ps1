#Requires -Version 7
function Get-HaloPKCEChallenge {
    <#
    .SYNOPSIS
        Generates a PKCE code verifier and S256 code challenge.
    .DESCRIPTION
        Returns a random RFC 7636 code verifier and its base64url-encoded SHA256 code challenge.
    .OUTPUTS
        A PSCustomObject with Verifier and Challenge properties.
    #>
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param ()
    $Verifier = ConvertTo-HaloBase64Url -Bytes ([System.Security.Cryptography.RandomNumberGenerator]::GetBytes(32))
    $Hash = [System.Security.Cryptography.SHA256]::HashData([System.Text.Encoding]::ASCII.GetBytes($Verifier))
    return [PSCustomObject]@{
        Verifier = $Verifier
        Challenge = ConvertTo-HaloBase64Url -Bytes $Hash
    }
}

function ConvertTo-HaloBase64Url {
    <#
    .SYNOPSIS
        Encodes bytes as unpadded base64url.
    .DESCRIPTION
        Encodes a byte array using the URL-safe base64 alphabet without padding, as required by PKCE.
    .OUTPUTS
        The base64url-encoded string.
    #>
    [CmdletBinding()]
    [OutputType([String])]
    param (
        # The bytes to encode.
        [Parameter(
            Mandatory = $True
        )]
        [Byte[]]$Bytes
    )
    return [Convert]::ToBase64String($Bytes).TrimEnd('=').Replace('+', '-').Replace('/', '_')
}

function Get-HaloAuthorisationResultPage {
    <#
    .SYNOPSIS
        Returns the HTML shown in the browser after the Halo sign-in redirect.
    .DESCRIPTION
        Builds a small self-contained page telling the user whether sign-in succeeded. Browsers only allow script to close tabs that script opened, so window.close() is attempted but the message covers the usual case where it is ignored.
    .OUTPUTS
        The HTML document as a string.
    #>
    [CmdletBinding()]
    [OutputType([String])]
    param (
        # Whether the sign-in succeeded.
        [Parameter(
            Mandatory = $True
        )]
        [Bool]$Success
    )
    if ($Success) {
        $Title = 'Signed in to Halo'
        $Message = 'You can close this tab and return to PowerShell.'
        $Colour = '#1a7f37'
        $Script = '<script>setTimeout(function () { window.close(); }, 1500);</script>'
    } else {
        $Title = 'Halo sign-in failed'
        $Message = 'Check the PowerShell window for details.'
        $Colour = '#cf222e'
        $Script = ''
    }
    $Template = @'
<!doctype html>
<html lang="en"><head><meta charset="utf-8"><title>{{TITLE}}</title>
<style>
  body { margin: 0; min-height: 100vh; display: grid; place-items: center; font-family: system-ui, sans-serif; background: #f6f8fa; color: #1f2328; }
  .card { text-align: center; padding: 2rem 2.5rem; background: #fff; border-radius: 12px; box-shadow: 0 1px 3px rgba(0,0,0,.12); }
  h1 { margin: 0 0 .5rem; font-size: 1.4rem; color: {{COLOUR}}; }
  p { margin: 0; }
  @media (prefers-color-scheme: dark) { body { background: #0d1117; color: #e6edf3; } .card { background: #161b22; } }
</style></head>
<body><div class="card"><h1>{{TITLE}}</h1><p>{{MESSAGE}}</p></div>{{SCRIPT}}</body></html>
'@
    return $Template.Replace('{{TITLE}}', $Title).Replace('{{MESSAGE}}', $Message).Replace('{{COLOUR}}', $Colour).Replace('{{SCRIPT}}', $Script)
}

function Wait-HaloAuthorisationCode {
    <#
    .SYNOPSIS
        Opens the Halo sign-in page and waits for the authorisation code redirect.
    .DESCRIPTION
        Starts a temporary HTTP listener on the redirect URI, opens the login URI in the default browser and waits for Halo to redirect back with an authorisation code. Validates the returned state value.
    .OUTPUTS
        The authorisation code.
    #>
    [CmdletBinding()]
    [OutputType([String])]
    param (
        # The fully built Halo authorise URI including query parameters.
        [Parameter(
            Mandatory = $True
        )]
        [URI]$LoginURI,
        # The redirect URI registered on the Halo API application.
        [Parameter(
            Mandatory = $True
        )]
        [URI]$RedirectURI,
        # The state value sent with the request, used to validate the response.
        [Parameter(
            Mandatory = $True
        )]
        [String]$State,
        # How long to wait for the user to complete sign-in, in seconds.
        [Int]$TimeoutSeconds = 300
    )
    if (-not $RedirectURI.AbsolutePath.EndsWith('/')) {
        throw 'RedirectURI must have a trailing slash so the Halo redirect URI matches the listener prefix.'
    }
    $Prefix = $RedirectURI.GetLeftPart([System.UriPartial]::Path)
    $Listener = [System.Net.HttpListener]::New()
    $Listener.Prefixes.Add($Prefix)
    try {
        $Listener.Start()
    } catch {
        throw ('Could not listen on {0} for the Halo sign-in redirect. Check the port is free or pass a different -RedirectURI (it must match the redirect URI on the Halo API application). {1}' -f $Prefix, $_.Exception.Message)
    }
    try {
        Write-Information -MessageData ('Opening your browser to sign in to Halo. If it does not open, browse to:{0}{1}' -f [Environment]::NewLine, $LoginURI.AbsoluteUri) -InformationAction Continue
        try {
            Start-Process -FilePath $LoginURI.AbsoluteUri
        } catch {
            Write-Warning ('Could not open a browser automatically: {0}' -f $_.Exception.Message)
        }
        $Deadline = (Get-Date).AddSeconds($TimeoutSeconds)
        $PendingContext = $Listener.GetContextAsync()
        while (-not $PendingContext.Wait(500)) {
            if ((Get-Date) -gt $Deadline) {
                throw ('Timed out after {0} seconds waiting for the Halo sign-in to complete.' -f $TimeoutSeconds)
            }
        }
        $Context = $PendingContext.Result
        $ResponseParameters = [System.Web.HttpUtility]::ParseQueryString($Context.Request.Url.Query)
        $Success = (-not [String]::IsNullOrEmpty($ResponseParameters['code'])) -and ($ResponseParameters['state'] -eq $State)
        $PageBytes = [System.Text.Encoding]::UTF8.GetBytes((Get-HaloAuthorisationResultPage -Success $Success))
        $Context.Response.ContentType = 'text/html; charset=utf-8'
        $Context.Response.ContentLength64 = $PageBytes.Length
        $Context.Response.OutputStream.Write($PageBytes, 0, $PageBytes.Length)
        $Context.Response.OutputStream.Close()
        $Context.Response.Close()
        # Give the browser a moment to read the page before the listener is torn down.
        Start-Sleep -Milliseconds 500
    } finally {
        $Listener.Stop()
        $Listener.Close()
    }
    if ($ResponseParameters['error']) {
        throw ('Halo returned ''{0}'' during sign-in: {1}' -f $ResponseParameters['error'], $ResponseParameters['error_description'])
    }
    if ($ResponseParameters['state'] -ne $State) {
        throw 'The Halo sign-in response state did not match the request.'
    }
    if ([String]::IsNullOrEmpty($ResponseParameters['code'])) {
        throw 'The Halo sign-in response did not include an authorisation code.'
    }
    return $ResponseParameters['code']
}

function Invoke-HaloAuthorisationCodeFlow {
    <#
    .SYNOPSIS
        Signs in to Halo through the browser using the authorisation code flow with PKCE.
    .DESCRIPTION
        Builds the authorise request from the connection information, waits for the user to sign in through the browser and exchanges the returned code for tokens.
    .OUTPUTS
        The parsed token endpoint response.
    #>
    [CmdletBinding()]
    [OutputType([Object])]
    param (
        # The connection information built by Connect-HaloAPI.
        [Parameter(
            Mandatory = $True
        )]
        [Object]$ConnectionInformation
    )
    $PKCE = Get-HaloPKCEChallenge
    $State = ConvertTo-HaloBase64Url -Bytes ([System.Security.Cryptography.RandomNumberGenerator]::GetBytes(16))
    $LoginURIBuilder = [System.UriBuilder]::New($ConnectionInformation.AuthoriseURI)
    $LoginQuery = [System.Web.HttpUtility]::ParseQueryString($LoginURIBuilder.Query)
    $LoginQuery['response_type'] = 'code'
    $LoginQuery['client_id'] = $ConnectionInformation.ClientID
    $LoginQuery['redirect_uri'] = $ConnectionInformation.RedirectURI
    $LoginQuery['scope'] = $ConnectionInformation.AuthScopes
    $LoginQuery['state'] = $State
    $LoginQuery['code_challenge'] = $PKCE.Challenge
    $LoginQuery['code_challenge_method'] = 'S256'
    $LoginURIBuilder.Query = $LoginQuery.ToString()
    $WaitParams = @{
        LoginURI = $LoginURIBuilder.Uri
        RedirectURI = $ConnectionInformation.RedirectURI
        State = $State
    }
    if ($ConnectionInformation.LoginTimeout) {
        $WaitParams.TimeoutSeconds = $ConnectionInformation.LoginTimeout
    }
    $Code = Wait-HaloAuthorisationCode @WaitParams
    $TokenRequestParams = @{
        Uri = $ConnectionInformation.AuthURI
        Method = 'POST'
        Body = @{
            grant_type = 'authorization_code'
            client_id = $ConnectionInformation.ClientID
            code = $Code
            redirect_uri = $ConnectionInformation.RedirectURI
            code_verifier = $PKCE.Verifier
        }
        ContentType = 'application/x-www-form-urlencoded'
        Headers = $ConnectionInformation.AdditionalHeaders
    }
    $TokenResponse = Invoke-WebRequest @TokenRequestParams
    return ConvertFrom-Json -InputObject $TokenResponse.Content
}
