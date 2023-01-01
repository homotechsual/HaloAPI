function Remove-HaloItem {
    <#
        .SYNOPSIS
           Removes an item from the Halo API.
        .DESCRIPTION
            Deletes a specific item from Halo.
        .OUTPUTS
            A powershell object containing the response.
    #>
    [cmdletbinding( SupportsShouldProcess = $True, ConfirmImpact = 'High' )]
    [OutputType([Object])]
    Param(
        # The item ID
        [Parameter( Mandatory = $True )]
        [int64]$ItemId
    )
    Invoke-HaloPreFlightCheck
    try {
        $ObjectToDelete = Get-HaloItem -ItemId $ItemId
        if ($ObjectToDelete) {
            if ($PSCmdlet.ShouldProcess("Item '$($ObjectToDelete.id)'", 'Delete')) {
                $Resource = "api/item/$($ItemId)"
                $ItemResults = New-HaloDELETERequest -Resource $Resource
                Return $ItemResults
            }
        } else {
            Throw 'Item was not found in Halo to delete.'
        }
    } catch {
        New-HaloError -ErrorRecord $_
    }
}