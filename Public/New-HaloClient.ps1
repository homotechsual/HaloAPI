#Requires -Version 7
function New-HaloClient {
    <#
        .SYNOPSIS
            Create or update client in the Halo API.
        .DESCRIPTION
            Allows the creation or update of clients in Halo
        .OUTPUTS
            A powershell object containing the response.
    #>
    [CmdletBinding()]
    Param(
        # If Updating
        [switch]$Update,
        # Client Object
        [PSCustomObject]$Client        
    )

    try {
        if ($Update) {
            Write-Verbose "Performing Update"
            if ($null -eq $Client.id){
                Throw "Updates must have ID"
            }
        } else {
            Write-Verbose "Performing Creation"
            if ($null -ne $Client.id){
                Throw "Creation must not have ID"
            }
        }
 
        $RequestParams = @{
            Method = "POST"
            Resource = "api/client"
            Body = $Client | ConvertTo-Json -Depth 100 -AsArray
        }
        $ClientResults = Invoke-HaloRequest @RequestParams
        Return $ClientResults
    } catch {
        Write-Error "Failed to create/update client in the Halo API. You'll see more detail if using '-Verbose'"
        Write-Verbose "$_"
    }
}