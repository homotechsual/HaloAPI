Function New-HaloItem {
    <#
        .SYNOPSIS
            Creates an item via the Halo API.
        .DESCRIPTION
            Function to send an item creation request to the Halo API
        .OUTPUTS
            Outputs an object containing the response from the web request.
    #>
    [CmdletBinding( SupportsShouldProcess = $True )]
    [OutputType([Object])]
    Param (
        # Object containing properties and values used to create a new item.
        [Parameter( Mandatory = $True )]
        [Object]$Item
    )
    try {
        if ($PSCmdlet.ShouldProcess("Item '$($Item.name)'", "Create")) {
            New-HaloPOSTRequest -Object $Item -Endpoint "item"
        }
    } catch {
        Write-Error "Failed to create item with the Halo API. You'll see more detail if using '-Verbose'"
        Write-Verbose "$_"
    }
}