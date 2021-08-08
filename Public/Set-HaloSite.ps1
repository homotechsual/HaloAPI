Function Set-HaloSite {
    <#
    .SYNOPSIS
        Updates a site via the Halo API.
    .DESCRIPTION
        Function to send a site update request to the Halo API
    .OUTPUTS
        Outputs an object containing the response from the web request.
    #>
    [CmdletBinding()]
    Param (
        [Parameter( Mandatory = $True )]
        [PSCustomObject]$Site
    )
    Invoke-HaloUpdate -Object $Site -Endpoint "site" -Update
}