Function Set-HaloItem {
    <#
    .SYNOPSIS
        Updates an item via the Halo API.
    .DESCRIPTION
        Function to send an item update request to the Halo API
    .OUTPUTS
        Outputs an object containing the response from the web request.
    #>
    [CmdletBinding()]
    Param (
        [Parameter( Mandatory = $True )]
        [PSCustomObject]$Item
    )
    Invoke-HaloUpdate -Object $Item -Endpoint "item" -Update
}