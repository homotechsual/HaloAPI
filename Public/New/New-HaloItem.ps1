Function New-HaloItem {
    <#
        .SYNOPSIS
            Creates one or more items via the Halo API.
        .DESCRIPTION
            Function to send an item creation request to the Halo API
        .OUTPUTS
            Outputs an object containing the response from the web request.
    #>
    [CmdletBinding( SupportsShouldProcess = $True )]
    [OutputType([Object[]])]
    Param (
        # Object or array of objects containing properties and values used to create one or more new items.
        [Parameter( Mandatory = $True )]
        [Object[]]$Item
    )
    Invoke-HaloPreFlightCheck
    try {
        if ($PSCmdlet.ShouldProcess($Item -is [Array] ? 'Items' : 'Item', 'Create')) {
            New-HaloPOSTRequest -Object $Item -Endpoint 'item'
        }
    } catch {
        New-HaloError -ErrorRecord $_
    }
}