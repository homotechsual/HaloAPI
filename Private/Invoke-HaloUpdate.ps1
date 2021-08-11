#Requires -Version 7
function Invoke-HaloUpdate {
    <#
    .SYNOPSIS
        Sends a formatted web request to the Halo API.
    .DESCRIPTION
        Wrapper function to send new or set requests to the Halo API
    .OUTPUTS
        Outputs an object containing the response from the web request.
    #>
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
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
    try {
        if ($Update) {
            if ($null -eq $Object.id) {
                Throw "Updates must have an ID"
            } else {
                $Operation = "update"
                Write-Verbose "Updating $($Endpoint)"
            }
        } else {
            if ($null -ne $Object.id) {
                Throw "Creates must not have an ID"
            } else {
                $Operation = "create"
                Write-Verbose "Creating $($Endpoint)"
            }
        }
        $WebRequestParams = @{
            Method = "POST"
            Resource = "api/$Endpoint"
            Body = $Object | ConvertTo-Json -Depth 100 -AsArray
        }
        $UpdateResults = Invoke-HaloRequest -WebRequestParams $WebRequestParams
        Return $UpdateResults
    } catch {
        Write-Error "Failed to $operation $Endpoint in the Halo API. You'll see more detail if using '-Verbose'"
        Write-Verbose "$_"
    }
}