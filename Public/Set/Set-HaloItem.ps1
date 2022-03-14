Function Set-HaloItem {
    <#
        .SYNOPSIS
            Updates one or more items via the Halo API.
        .DESCRIPTION
            Function to send an item update request to the Halo API
        .OUTPUTS
            Outputs an object containing the response from the web request.
    #>
    [CmdletBinding( SupportsShouldProcess = $True )]
    [OutputType([Object[]])]
    Param (
        # Object or array of objects containing properties and values used to update one or more existing items.
        [Parameter( Mandatory = $True, ValueFromPipeline )]
        [Object[]]$Item
    )
    Invoke-HaloPreFlightCheck
    try {
        $ObjectToUpdate = $False
        ForEach-Object -InputObject $Item {
            $HaloItemParams = @{
                ItemId = $_.id
            }
            $ItemExists = Get-HaloItem @HaloItemParams
            if ($ItemExists) {
                Set-Variable -Scope 1 -Name 'ObjectToUpdate' -Value $True
            }
        }
        if ($ObjectToUpdate) {
            if ($PSCmdlet.ShouldProcess($Item -is [Array] ? 'Items' : 'Item', 'Update')) {
                New-HaloPOSTRequest -Object $Item -Endpoint 'item' -Update
            }
        } else {
            Throw 'One or more items was not found in Halo to update.'
        }
    } catch {
        New-HaloError -ErrorRecord $_
    }
}