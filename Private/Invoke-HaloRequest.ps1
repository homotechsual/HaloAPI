#Requires -Version 7
function Invoke-HaloRequest {
    <#
    .SYNOPSIS
        Sends a formatted web request to the Halo API.
    .DESCRIPTION
        Wrapper function to send web requests to the Halo API and handle authentication as well as catching errors.
    .EXAMPLE
        PS C:\> Invoke-HaloRequest -Method "GET" -Resource "/api/Articles"
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
        # Allows the request to be performed without authentication.
        [Switch]$AllowAnonymous,
        # Returns the Raw result. Useful for file downloads
        [Switch]$RawResult
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
    $WebRequestParams = @{
        ContentType = "application/json"
        Headers = $AuthHeaders
        Method = $Method
        Uri = "$($Script:HAPIConnectionInformation.URL)$($Resource)"
    }
    try {
        Write-Verbose "Making a $($WebRequestParams.Method) request to $($WebRequestParams.Uri)"
        switch ($Method) {
            {($_ -eq "PUT") -or ($_ -eq "POST") -or ($_ -eq "DELETE") -or ($_ -eq "PATCH")} {
                $Response = Invoke-WebRequest @WebRequestParams -Body $Body
            }
            {($_ -eq "GET")} {
                $Response = Invoke-WebRequest @WebRequestParams
            }
        }
        Write-Debug "Response headers: $($Response.Headers | Out-String)"
        if ($RawResult){
            $Results = $Response
        } else {
            $Results = $Response.Content | ConvertFrom-Json
        }
        return $Results
    } catch {
        $ExceptionResponse = $_.Exception.Response
        Write-Error "The Halo API request `($($ExceptionResponse.Method) $($ExceptionResponse.ReponseUri)`) responded with $($ExceptionResponse.StatusCode.Value__): $($ExceptionResponse.StatusDescription). You'll see more detail if using '-Verbose'"
        Write-Verbose $_
    }
}