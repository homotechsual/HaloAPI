Function Set-HaloSupplier {
    <#
        .SYNOPSIS
            Updates a supplier via the Halo API.
        .DESCRIPTION
            Function to send a supplier update request to the Halo API
        .OUTPUTS
            Outputs an object containing the response from the web request.
    #>
    [CmdletBinding( SupportsShouldProcess = $True )]
    [OutputType([Object])]
    Param (
        # Object containing properties and values used to update an existing supplier.
        [Parameter( Mandatory = $True )]
        [Object]$Supplier
    )
    try {
        $ObjectToUpdate = Get-HaloSupplier -SupplierID $Supplier.id
        if ($ObjectToUpdate) {
            if ($PSCmdlet.ShouldProcess("Supplier '$($ObjectToUpdate.name)'", "Update")) {
                New-HaloPOSTRequest -Object $Supplier -Endpoint "supplier" -Update
            }
        } else {
            Throw "Supplier was not found in Halo to update."
        }
    } catch {
        Write-Error "Failed to update supplier with the Halo API. You'll see more detail if using '-Verbose'"
        Write-Verbose "$_"
    }
}