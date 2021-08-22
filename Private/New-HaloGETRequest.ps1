function New-HaloGETRequest {
    <#
        .SYNOPSIS
            Builds a request for the Halo API.
        .DESCRIPTION
            Wrapper function to build web requests for the Halo API.
        .EXAMPLE
            PS C:\> New-HaloGETRequest -Method "GET" -Resource "/api/Articles"
            Gets all Knowledgebase Articles
        .OUTPUTS
            Outputs an object containing the response from the web request.
    #>
    [CmdletBinding()]
    [OutputType([Object])]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Private function - no need to support.')]
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
        # A hashtable used to build the query string.
        [Hashtable]$QSCollection,
        # Disables auto pagination.
        [Switch]$AutoPaginateOff,
        # The key for the results object.
        [String]$ResourceType
    )
    Invoke-HaloPreFlightChecks
    try {
        if (($null -ne $QSCollection) -and ($QSCollection.pageinate -eq 'true') -and (-not($AutoPaginateOff))) {
            Write-Verbose 'Automatically paginating.'
            $PageNum = $QSCollection.page_no
            $PageSize = $QSCollection.page_size
        } elseif ((-not $QSCollection.pageinate) -and ($QSCollection.page_size)) {
            $QSCollection.Remove('page_size')
        }
        if ($QSCollection) {
            Write-Debug "Query string in New-HaloGETRequest contains: $($QSCollection | Out-String)"
            $QueryStringCollection = [system.web.httputility]::ParseQueryString([string]::Empty)
            Write-Verbose 'Building [HttpQSCollection] for New-HaloGETRequest'
            foreach ($Key in $QSCollection.Keys) {
                $QueryStringCollection.Add($Key, $QSCollection.$Key)
            }
        } else {
            Write-Debug 'Query string collection not present...'
        }
        $QSBuilder = [System.UriBuilder]::new()
        if ($AutoPaginateOff) {
            Write-Debug 'Automatic pagination is off.'
            $QSBuilder.Query = $QueryStringCollection.ToString()
            $Query = $QSBuilder.Query.ToString()
            $WebRequestParams = @{
                Method = $Method
                Uri = "$($Script:HAPIConnectionInformation.URL)$($Resource)$($Query)"
            }
            Write-Debug "Building new HaloRequest with params: $($WebRequestParams | Out-String)"
            $Response = Invoke-HaloRequest -WebRequestParams $WebRequestParams -RawResult:$RawResult
            Write-Debug "Halo request returned $($Response | Out-String)"
            if (($Response.PSObject.Properties.name -match $ResourceType) -and ($Response.$ResourceType -is [Object])) {
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
                    Method = $Method
                    Uri = "$($Script:HAPIConnectionInformation.URL)$($Resource)$($Query)"
                }
                Write-Debug "Building new HaloRequest with params: $($WebRequestParams | Out-String)"
                $Response = Invoke-HaloRequest -WebRequestParams $WebRequestParams -RawResult:$RawResult
                Write-Debug "Halo request returned $($Response | Out-String)"
                $NumPages = [Math]::Ceiling($Response.record_count / $PageSize)
                Write-Verbose "Total number of pages to process: $NumPages"
                $PageNum++
                if (($Response.PSObject.Properties.name -match $ResourceType) -and ($Response.$ResourceType -is [Object])) {
                    $Response.$ResourceType
                } else {
                    $Response
                }
            } while ($PageNum -lt $NumPages)
        }
        Return $Result
    } catch {
        $ErrorRecord = @{
            ExceptionType = 'System.Net.Http.HttpRequestException'
            ErrorMessage = 'GET request sent to the Halo API failed.'
            InnerException = $_.Exception
            ErrorID = 'HaloGETRequestFailed'
            ErrorCategory = 'ProtocolError'
            TargetObject = $_.TargetObject
            ErrorDetails = $_.ErrorDetails
            BubbleUpDetails = $True
        }
        $RequestError = New-HaloErrorRecord @ErrorRecord
        $PSCmdlet.ThrowTerminatingError($RequestError)
    }
}