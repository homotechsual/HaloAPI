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
            if ($null -eq $Object.id){
                Throw "Updates must have an ID"
            } else {
                Write-Verbose "Updating $($Endpoint)"
            }
        } else {
            if ($null -ne $Object.id){
                Throw "Creates must not have an ID"
            } else {
                Write-Verbose "Creating $($Endpoint)"
            }
        }
 
        $WebRequestParams = @{
            Method = "POST"
            Resource = "api/$Endpoint"
            Body = $Object | ConvertTo-Json -Depth 100 -AsArray
        }
        $ClientResults = Invoke-HaloRequest -WebRequestParams $WebRequestParams
        Return $ClientResults
    } catch {
        Write-Error "Failed to create/update $Endpoint in the Halo API. You'll see more detail if using '-Verbose'"
        Write-Verbose "$_"
    }
}