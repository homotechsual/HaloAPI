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
    [OutputType([Object])]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Private function - no need to support.')]
    Param(
        # If Updating
        [switch]$Update,
        # Object to Update / Create
        [Parameter( Mandatory = $True )]
        [PSCustomObject]$Object,
        # Endpoint to use
        [Parameter( Mandatory = $True )]
        [string]$Endpoint
    )
    Invoke-HaloPreFlightCheck
    try {
        if ($Update) {
            if ($null -eq $Object.id) {
                Throw 'Updates must have an ID'
            }
        } else {
            if ($null -ne $Object.id) {
                Throw 'Creates must not have an ID'
            }
        }
        $WebRequestParams = @{
            Method = 'POST'
            Uri = "$($Script:HAPIConnectionInformation.URL)api/$Endpoint"
            Body = $Object | ConvertTo-Json -Depth 100 -AsArray
        }
        $UpdateResults = Invoke-HaloRequest -WebRequestParams $WebRequestParams
        Return $UpdateResults
    } catch {
        $ErrorRecord = @{
            ExceptionType = 'System.Net.Http.HttpRequestException'
            ErrorMessage = 'POST request sent to the Halo API failed.'
            InnerException = $_.Exception
            ErrorID = 'HaloPOSTRequestFailed'
            ErrorCategory = 'ProtocolError'
            TargetObject = $_.TargetObject
            ErrorDetails = $_.ErrorDetails
            BubbleUpDetails = $True
        }
        $RequestError = New-HaloErrorRecord @ErrorRecord
        $PSCmdlet.ThrowTerminatingError($RequestError)
    }
}