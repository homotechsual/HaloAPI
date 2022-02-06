#Requires -Version 7
function New-HaloDELETERequest {
    <#
    .SYNOPSIS
        Sends a formatted web request to the Halo API.
    .DESCRIPTION
        Wrapper function to send delete requests to the Halo API
    .OUTPUTS
        Outputs an object containing the response from the web request.
    #>
    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Private function - no need to support.')]
    [OutputType([Object])]
    Param(
        # Endpoint for Delete Request
        [Parameter( Mandatory = $True )]
        [string]$Resource
    )
    Invoke-HaloPreFlightCheck
    try {
        $WebRequestParams = @{
            Method = 'DELETE'
            Uri = "$($Script:HAPIConnectionInformation.URL)$($Resource)"
        }
        $DeleteResults = Invoke-HaloRequest -WebRequestParams $WebRequestParams
        Return $DeleteResults
    } catch [Microsoft.PowerShell.Commands.HttpResponseException] {
        throw $_
    } catch {
        New-HaloError -ErrorRecord $_
    }
}