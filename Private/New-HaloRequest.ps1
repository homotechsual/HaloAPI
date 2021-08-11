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
        # Returns the Raw result. Useful for file downloads
        [Switch]$RawResult,
        # The request body to send.
        [String]$Body,
        # A hashtable used to build the query string.
        [Hashtable]$QSCollection,
        # Disables auto pagination.
        [Switch]$AutoPaginateOff,
        # The key for the results object.
        [String]$ResourceType
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
    } elseif ((-not $QSCollection.pageinate) -and ($QSCollection.page_size)) {
        $QSCollection.Remove("page_size")
    }
    if ($QSCollection) {
        Write-Debug "Query string in New-HaloRequest contains: $($QSCollection | Out-String)"
        $QueryStringCollection = [system.web.httputility]::ParseQueryString([string]::Empty)
        Write-Verbose "Building [HttpQSCollection] for New-HaloRequest"
        foreach ($Key in $QSCollection.Keys) {
            $QueryStringCollection.Add($Key, $QSCollection.$Key)
        }
    } else {
        Write-Debug "Query string collection not present..."
    }
    $QSBuilder = [System.UriBuilder]::new()
    if ($AutoPaginateOff) {
        Write-Debug "Automatic pagination is off."
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
        Write-Debug "Halo request returned $($Response | Out-String)"
        if ($Response.PSObject.Properties.name -match $ResourceType) {
            $Result = $Response.$ResourceType
        } else {
            $Result = $Response
        }
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
            Write-Debug "Halo request returned $($Response | Out-String)"
            $NumPages = [Math]::Ceiling($Response.record_count / $PageSize)
            Write-Verbose "Total number of pages to process: $NumPages"
            $PageNum++
            if ($Response.PSObject.Properties.name -match $ResourceType) {
                $Response.$ResourceType
            } else {
                $Response
            }
        } while ($PageNum -lt $NumPages)
    }
    Return $Result
}