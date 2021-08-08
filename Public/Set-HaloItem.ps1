Function Set-HaloItem {
    <#
    .SYNOPSIS
        Updates an Item via the Halo API.
    .DESCRIPTION
        Function to send an Item update request to the Halo API
    .OUTPUTS
        Outputs an object containing the response from the web request.
    #>
    [CmdletBinding()]
    Param (
        [Parameter( Mandatory = $True )]
        [PSCustomObject]$Item
    )
    Invoke-HaloUpdate -Object $Item -Endpoint "Item" -update
}