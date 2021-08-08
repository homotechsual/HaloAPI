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
        # End Point to use
        [Parameter( Mandatory = $True )]
        [string]$Endpoint
    )

    try {
        if ($Update) {
            Write-Verbose "Performing Update"
            if ($null -eq $Object.id){
                Throw "Updates must have ID"
            }
        } else {
            Write-Verbose "Performing Creation"
            if ($null -ne $Object.id){
                Throw "Creation must not have ID"
            }
        }
 
        $RequestParams = @{
            Method = "POST"
            Resource = "api/$Endpoint"
            Body = $Object | ConvertTo-Json -Depth 100 -AsArray
        }
        $ClientResults = Invoke-HaloRequest @RequestParams
        Return $ClientResults
    } catch {
        Write-Error "Failed to create/update $Endpoint in the Halo API. You'll see more detail if using '-Verbose'"
        Write-Verbose "$_"
    }
}