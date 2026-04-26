#Requires -Version 7
function New-HaloPOSTRequest {
    <#
    .SYNOPSIS
        Sends a formatted web request to the Halo API.
    .DESCRIPTION
        Wrapper function to send new or set requests to the Halo API
    .OUTPUTS
        Outputs an object containing the response from the web request.
    #>
    [CmdletBinding()]
    [OutputType([Object[]])]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Private function - no need to support.')]
    Param(
        # Object to Update / Create
        [Parameter( Mandatory = $True )]
        [Object[]]$Object,
        # Endpoint to use
        [Parameter( Mandatory = $True )]
        [string]$Endpoint,
        # A hashtable used to build the query string.
        [Hashtable]$QSCollection
    )
    Invoke-HaloPreFlightCheck
    try {
        if ($QSCollection) {
            Write-Debug ('Query string in New-HaloPOSTRequest contains: {0}' -f ($QSCollection | Out-String))
            $QueryStringCollection = [system.web.httputility]::ParseQueryString([string]::Empty)
            Write-Verbose 'Building [HttpQSCollection] for New-HaloPOSTRequest'
            foreach ($Key in $QSCollection.Keys) {
                $QueryValue = $QSCollection[$Key]
                if ($QueryValue -is [array]) {
                    foreach ($Entry in $QueryValue) {
                        $QueryStringCollection.Add($Key, $Entry)
                    }
                } else {
                    $QueryStringCollection.Add($Key, $QueryValue)
                }
            }
            $QSBuilder = [System.UriBuilder]::new()
            $QSBuilder.Query = $QueryStringCollection.ToString()
            $Query = $QSBuilder.Query.ToString()
        } else {
            Write-Debug 'Query string collection not present...'
        }
        $JSONBody = $Object | ConvertTo-Json -Depth 100 -AsArray
        Write-Debug ('Request body:{0}{1}' -f [Environment]::NewLine, $JSONBody)
        $WebRequestParams = @{
            Method = 'POST'
            Uri = ('{0}api/{1}{2}' -f $Script:HAPIConnectionInformation.URL, $Endpoint, $Query)
            Body = $JSONBody
        }
        $Results = Invoke-HaloRequest -WebRequestParams $WebRequestParams
        Return $Results
    } catch [Microsoft.PowerShell.Commands.HttpResponseException] {
        throw $_
    } catch {
        New-HaloError -ErrorRecord $_
    }
}