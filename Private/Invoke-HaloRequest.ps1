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
    param (
        # Hashtable containing the web request parameters.
        [Hashtable]$WebRequestParams,
        # Returns the Raw result. Useful for file downloads.
        [Switch]$RawResult
    )
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
        Write-Verbose $ExceptionResponse | Out-String
        Write-Error "The Halo API request `($($ExceptionResponse.Method) $($ExceptionResponse.ReponseUri)`) responded with $($ExceptionResponse.StatusCode.Value__): $($ExceptionResponse.StatusDescription). You'll see more detail if using '-Verbose'"
        Write-Verbose $_
    }
}

