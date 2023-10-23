function Remove-HaloSupplier {
    <#
        .SYNOPSIS
           Removes a supplier from the Halo API.
        .DESCRIPTION
            Deletes a specific supplier from Halo.
        .OUTPUTS
            A powershell object containing the response.
    #>
    [cmdletbinding( SupportsShouldProcess = $True, ConfirmImpact = 'High' )]
    [OutputType([Object])]
    Param(
        # The Supplier ID
        [Parameter( Mandatory, ParameterSetName = 'Single' )]
        [int64]$SupplierID
    )
    Invoke-HaloPreFlightCheck
    try {
        $ObjectToDelete = Get-HaloSupplier -SupplierID $SupplierID
        if ($ObjectToDelete) {
            if ($PSCmdlet.ShouldProcess("Action '$($ObjectToDelete.id)' by '$($ObjectToDelete.who)'", 'Delete')) {
                $Resource = "api/supplier/$($SupplierID)"
                $SupplierResults = New-HaloDELETERequest -Resource $Resource
                Return $SupplierResults
            }
        } else {
            Throw 'Supplier was not found in Halo to delete.'
        }
    } catch {
        New-HaloError -ErrorRecord $_
    }
}
