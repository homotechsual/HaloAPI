Function Set-HaloItem {
    <#
        .SYNOPSIS
            Updates an item via the Halo API.
        .DESCRIPTION
            Function to send an item update request to the Halo API
        .OUTPUTS
            Outputs an object containing the response from the web request.
    #>
    [CmdletBinding( SupportsShouldProcess = $True )]
    [OutputType([PSCustomObject])]
    Param (
        # Object containing properties and values used to update an existing item.
        [Parameter( Mandatory = $True )]
        [PSCustomObject]$Item
    )
    if ($PSCmdlet.ShouldProcess("Asset", "Update")) {
        Invoke-HaloUpdate -Object $Item -Endpoint "item" -Update
    }
}