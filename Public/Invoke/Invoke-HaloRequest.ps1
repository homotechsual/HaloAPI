#Requires -Version 7

function Invoke-HaloRequest {
    <#
        .SYNOPSIS
            Sends a request to the Halo API.
        .DESCRIPTION
            Wrapper function to send web requests to the Halo API.

            Supports the legacy hashtable request format used internally by the module,
            as well as a direct parameter set for clearer public use.

            When using -Fragment, slashless values are treated as Halo API fragments and
            are automatically prefixed with /api/.
        .PARAMETER WebRequestParams
            Hashtable containing the web request parameters.
        .PARAMETER Method
            HTTP method for the request.
        .PARAMETER Uri
            Absolute URI for the request.
        .PARAMETER Fragment
            Fragment path to resolve against the Halo base URL. Slashless fragments are
            automatically prefixed with /api/.
        .PARAMETER Headers
            Request headers to merge with the Halo auth headers.
        .PARAMETER Body
            Request body.
        .PARAMETER ContentType
            Content type for the request.
        .PARAMETER RawResult
            Returns the raw web response. Useful for file downloads.
        .EXAMPLE
            Invoke-HaloRequest -WebRequestParams @{ Method = 'GET'; Uri = 'https://example.halo/api/customtable' }

            Uses the legacy request hashtable.
        .EXAMPLE
            Invoke-HaloRequest -Method 'POST' -Uri 'https://example.halo/api/customtable' -Body $Payload

            Uses the direct parameter set for a POST request with an explicit absolute URI.
        .EXAMPLE
            Invoke-HaloRequest -Method 'GET' -Fragment 'tickets'

            Resolves a slashless fragment to /api/tickets before sending the request.
        .OUTPUTS
            Outputs an object containing the response from the web request.
    #>
    [Cmdletbinding()]
    [OutputType([Object])]
    param (
        # Hashtable containing the web request parameters.
        [Parameter( ParameterSetName = 'WebRequestParams', Mandatory = $True )]
        [Hashtable]$WebRequestParams,
        # HTTP method for the request.
        [Parameter( ParameterSetName = 'RequestParameters', Mandatory = $True )]
        [string]$Method,
        # URI or path for the request.
        [Parameter( ParameterSetName = 'RequestParameters' )]
        [string]$Uri,
        # Fragment path to resolve against the Halo base URL.
        [Parameter( ParameterSetName = 'RequestParameters' )]
        [string]$Fragment,
        # Request headers to merge with the Halo auth headers.
        [Parameter( ParameterSetName = 'RequestParameters' )]
        [Hashtable]$Headers,
        # Request body.
        [Parameter( ParameterSetName = 'RequestParameters' )]
        [Object]$Body,
        # Content type for the request.
        [Parameter( ParameterSetName = 'RequestParameters' )]
        [string]$ContentType,
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
            Authorization = ('{0} {1}' -f $Script:HAPIAuthToken.Type, $Script:HAPIAuthToken.Access)
        }
        if ($null -ne $Script:HAPIConnectionInformation.AdditionalHeaders) {
            $RequestHeaders = $AuthHeaders + $Script:HAPIConnectionInformation.AdditionalHeaders
        } else {
            $RequestHeaders = $AuthHeaders
        }
    } else {
        $RequestHeaders = $null
    }
    if ($PSCmdlet.ParameterSetName -eq 'RequestParameters') {
        $WebRequestParams = @{
            Method = $Method
        }

        if (-not [string]::IsNullOrWhiteSpace($Uri)) {
            $WebRequestParams.Uri = $Uri
        }

        if (-not [string]::IsNullOrWhiteSpace($Fragment)) {
            $WebRequestParams.Fragment = $Fragment
        }

        if ($null -ne $Headers) {
            $WebRequestParams.Headers = $Headers
        }

        if ($PSBoundParameters.ContainsKey('Body')) {
            $WebRequestParams.Body = $Body
        }

        if ($PSBoundParameters.ContainsKey('ContentType')) {
            $WebRequestParams.ContentType = $ContentType
        }
    }
    $Retries = 0
    $BaseDelay = 5 # Base delay of 5 seconds
    $MaxDelay = 60 # Maximum delay of 60 seconds
    $BaseUri = [System.Uri]$Script:HAPIConnectionInformation.URL
    # Check for a fragment first so callers can supply just the path portion.
    if ($WebRequestParams.Fragment) {
        $FragmentPath = $WebRequestParams.Fragment
        if ($FragmentPath -notmatch '/') {
            $FragmentPath = '/api/{0}' -f $FragmentPath
        }

        $WebRequestParams.Uri = [System.Uri]::new($BaseUri, $FragmentPath).AbsoluteUri
        $WebRequestParams.Remove('Fragment') | Out-Null
    }

    # Check if $WebRequestParams contains a full URI, if not, append the base URL.
    if (-not ([System.Uri]$WebRequestParams.Uri).IsAbsoluteUri) {
        $WebRequestParams.Uri = [System.Uri]::new($BaseUri, $WebRequestParams.Uri).AbsoluteUri
    }
    if ($null -ne $WebRequestParams.Headers) {
        if ($null -ne $RequestHeaders) {
            $RequestHeaders = $RequestHeaders + $WebRequestParams.Headers
        } else {
            $RequestHeaders = $WebRequestParams.Headers
        }

        $WebRequestParams.Remove('Headers') | Out-Null
    }

    $RequestContentType = 'application/json; charset=utf-8'
    if ($WebRequestParams.ContainsKey('ContentType')) {
        $RequestContentType = $WebRequestParams.ContentType
        $WebRequestParams.Remove('ContentType') | Out-Null
    }
    do {
        $Retries++
        Write-Verbose ('Attempt {0} of 10' -f $Retries)
        try {
            Write-Verbose ('Making a {0} request to {1}' -f $WebRequestParams.Method, $WebRequestParams.Uri)
            $Response = Invoke-WebRequest @WebRequestParams -Headers $RequestHeaders -ContentType $RequestContentType
            if ($Response) {
                Write-Debug ('Response headers: {0}' -f ($Response.Headers | Out-String))
                Write-Debug ('Raw Response: {0}' -f ($Response | Out-String))
                Write-Debug ('Response Members: {0}' -f ($Response | Get-Member | Out-String))
                $Success = $True
                if ($RawResult) {
                    $Results = $Response
                } else {
                    $Results = ($Response.Content | ConvertFrom-Json -Depth 100)
                }
            } else {
                Write-Debug 'Response was null.'
            }
        } catch [Microsoft.PowerShell.Commands.HttpResponseException] {
            $Success = $False
            if ($_.Exception.Response.StatusCode.value__ -eq 429) {
                $WaitTime = [math]::Min($BaseDelay * [math]::Pow(2, $Retries - 1), $MaxDelay)
                Write-Warning ('The request was throttled, waiting for {0} seconds.' -f $WaitTime)
                Start-Sleep -Seconds $WaitTime
                continue
            } else {
                throw $_
                break
            }
        } catch {
            throw $_
        }
        Write-Verbose 'Request successful.'
    } while ((-not $Results) -and ($Retries -lt $Script:HAPIConnectionInformation.MaxRetries) -and (-not $Success))
    if ($Results) {
        Write-Verbose 'Request returned results.'
        Return $Results
    } else {
        Write-Verbose 'Request unsuccessful.'
        if ($Retries -gt 1) {
            New-HaloError -ModuleMessage ('Retried request to "{0}" {1} times, request unsuccessful.' -f $WebRequestParams.Uri, $Retries)
        }
    }
}
