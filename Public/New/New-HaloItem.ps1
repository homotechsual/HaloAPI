Function New-HaloItem {
    <#
    .SYNOPSIS
        Creates an item via the Halo API.
    .DESCRIPTION
        Function to send an item creation request to the Halo API
    .OUTPUTS
        Outputs an object containing the response from the web request.
    #>
    [CmdletBinding()]
    Param (
        # Object containing properties and values used to create a new item.
        [Parameter( Mandatory = $True )]
        [PSCustomObject]$Item
    )
    Invoke-HaloUpdate -Object $Item -Endpoint "item"
}