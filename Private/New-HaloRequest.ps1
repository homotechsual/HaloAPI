function New-HaloRequest {
    <#
        .SYNOPSIS
            Builds a request for the Halo API.
        .DESCRIPTION
            Wrapper function to build web requests for the Halo API.
        .EXAMPLE
            PS C:\> New-HaloRequest -Method "GET" -Resource "/api/Articles"
            Gets all Knowledgebase Articles
        .OUTPUTS
            Outputs an object containing the response from the web request.
    #>
    [CmdletBinding()]
    param (
        # The HTTP request method.
        [Parameter(
            Mandatory = $True
        )]
        [String]$Method,
        # The resource to send the request to.
        [Parameter(
            Mandatory = $True
        )]
        [String]$Resource,
        # The request body to send.
        [String]$Body,
        # A hashtable used to build the query string.
        [Hashtable]$QSCollection,
        # Allows the request to be performed without authentication.
        [Switch]$AllowAnonymous,
        # Returns the Raw result. Useful for file downloads
        [Switch]$RawResult,
        # Disables auto pagination.
        [Switch]$AutoPaginateOff
    )
    if ($null -eq $Script:HAPIConnectionInformation) {
        Throw "Missing Halo connection information, please run 'Connect-HaloAPI' first."
    }
    if (($null -eq $Script:HAPIAuthToken) -and ($null -eq $AllowAnonymous)) {
        Throw "Missing Halo authentication tokens, please add '-AllowAnonymous' to the PowerShell command to return public data (if supported)."
    }
    $Now = Get-Date 
    if ($Script:HAPIAuthToken.Expires -le $Now) {
        Write-Verbose "The auth token has expired, renewing."
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
    if (($null -ne $QSCollection) -and ($QSCollection.pageinate -eq 'true') -and (-not($AutoPaginateOff))) {
        Write-Verbose "Automatically paginating."
        $PageNum = $QSCollection.page_no
        $PageSize = $QSCollection.page_size
    }
    Write-Debug "Query string in New-HaloRequest contains: $($QSCollection | Out-String)"
    if ($QSCollection) {
        $QueryStringCollection = [system.web.httputility]::ParseQueryString([string]::Empty)
        Write-Verbose "Building [HttpQSCollection] for New-HaloRequest"
        foreach ($Key in $QSCollection.Keys) {
            $QueryStringCollection.Add($Key, $QSCollection.$Key)
        }
    } else {
        Write-Warning "Query string collection not present..."
    }
    $QSBuilder = [System.UriBuilder]::new()
    if ($AutoPaginateOff) {
        $QSBuilder.Query = $QueryStringCollection.ToString()
        $Query = $QSBuilder.Query.ToString()
        $WebRequestParams = @{
            ContentType = "application/json"
            Headers = $AuthHeaders
            Method = $Method
            Uri = "$($Script:HAPIConnectionInformation.URL)$($Resource)$($Query)"
        }
        Write-Debug "Building new HaloRequest with params: $($WebRequestParams | Out-String)"
        $Result = Invoke-HaloRequest -WebRequestParams $WebRequestParams -RawResult:$RawResult
    } elseif ($PageNum) {
        $Result = do {
            Write-Verbose "Processing page $PageNum"
            $QueryStringCollection.Remove('page_no')
            $QueryStringCollection.Add('page_no', $PageNum)
            $QSBuilder.Query = $QueryStringCollection.ToString()
            $Query = $QSBuilder.Query.ToString()
            $WebRequestParams = @{
                ContentType = "application/json"
                Headers = $AuthHeaders
                Method = $Method
                Uri = "$($Script:HAPIConnectionInformation.URL)$($Resource)$($Query)"
            }
            Write-Debug "Building new HaloRequest with params: $($WebRequestParams | Out-String)"
            $Response = Invoke-HaloRequest -WebRequestParams $WebRequestParams -RawResult:$RawResult
            $NumPages = [Math]::Ceiling($Response.record_count / $PageSize)
            Write-Verbose "Total number of pages to process: $NumPages"
            $PageNum++
            $Response | Select-Object "record_count", "users"
        } while ($PageNum -lt $NumPages)
    }
    Return $Result
}