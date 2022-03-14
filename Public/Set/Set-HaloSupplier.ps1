Function Set-HaloSupplier {
    <#
        .SYNOPSIS
            Updates one or more suppliers via the Halo API.
        .DESCRIPTION
            Function to send a supplier update request to the Halo API
        .OUTPUTS
            Outputs an object containing the response from the web request.
    #>
    [CmdletBinding( SupportsShouldProcess = $True )]
    [OutputType([Object[]])]
    Param (
        # Object or array of objects containing properties and values used to update one or more existing suppliers.
        [Parameter( Mandatory = $True, ValueFromPipeline )]
        [Object[]]$Supplier
    )
    Invoke-HaloPreFlightCheck
    try {
        $ObjectToUpdate = $False
        ForEach-Object -InputObject $Supplier {
            $HaloSupplierParams = @{
                SupplierId = $_.id
            }
            $SupplierExists = Get-HaloSupplier @HaloSupplierParams
            if ($SupplierExists) {
                Set-Variable -Scope 1 -Name 'ObjectToUpdate' -Value $True
            }
        }
        if ($ObjectToUpdate) {
            if ($PSCmdlet.ShouldProcess($Supplier -is [Array] ? 'Suppliers' : 'Supplier', 'Update')) {
                New-HaloPOSTRequest -Object $Supplier -Endpoint 'supplier' -Update
            }
        } else {
            Throw 'One or more suppliers was not found in Halo to update.'
        }
    } catch {
        New-HaloError -ErrorRecord $_
    }
}