#Requires -Version 7
function Invoke-HaloRemove {
    <#
    .SYNOPSIS
        Sends a formatted web request to the Halo API.
    .DESCRIPTION
        Wrapper function to send delete requests to the Halo API
    .OUTPUTS
        Outputs an object containing the response from the web request.
    #>
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    Param(
        # Endpoint for Delete Request
        [Parameter( Mandatory = $True )]
        [string]$Resource
    )
    try {
        $WebRequestParams = @{
            Method = "DELETE"
            Uri = "$($Script:HAPIConnectionInformation.URL)$($Resource)"
        }
        $DeleteResults = Invoke-HaloRequest -WebRequestParams $WebRequestParams
        Return $DeleteResults
    } catch {
        Write-Error "Failed to Delete $Resource in the Halo API. You'll see more detail if using '-Verbose'"
        Write-Verbose "$_"
    }
}