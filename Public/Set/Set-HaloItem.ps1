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
    [OutputType([Object])]
    Param (
        # Object containing properties and values used to update an existing item.
        [Parameter( Mandatory = $True, ValueFromPipeline )]
        [Object]$Item
    )
    Invoke-HaloPreFlightCheck
    try {
        $ObjectToUpdate = Get-HaloItem -ItemID $Item.id
        if ($ObjectToUpdate) {
            if ($PSCmdlet.ShouldProcess("Item '$($ObjectToUpdate.name)'", 'Update')) {
                New-HaloPOSTRequest -Object $Item -Endpoint 'item' -Update
            }
        } else {
            Throw 'Item was not found in Halo to update.'
        }
    } catch {
        New-HaloError -ErrorRecord $_
    }
}