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
        [string]$Endpoint
    )
    Invoke-HaloPreFlightCheck
    try {
        $WebRequestParams = @{
            Method = 'POST'
            Uri = "$($Script:HAPIConnectionInformation.URL)api/$Endpoint"
            Body = $Object | ConvertTo-Json -Depth 100 -AsArray
        }
        $UpdateResults = Invoke-HaloRequest -WebRequestParams $WebRequestParams
        Return $UpdateResults
    } catch [Microsoft.PowerShell.Commands.HttpResponseException] {
        throw $_
    } catch {
        New-HaloError -ErrorRecord $_
    }
}