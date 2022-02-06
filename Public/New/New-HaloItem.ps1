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
    Invoke-HaloPreFlightCheck
    try {
        if ($PSCmdlet.ShouldProcess("Item '$($Item.name)'", 'Create')) {
            New-HaloPOSTRequest -Object $Item -Endpoint 'item'
        }
    } catch {
        New-HaloError -ErrorRecord $_
    }
}