Function Remove-HaloSalesOrder {
    <#
        .SYNOPSIS
           Removes a sales order from the Halo API.
        .DESCRIPTION
            Deletes a specific sales order from Halo.
        .OUTPUTS
            A PowerShell object containing the response.
    #>
    [CmdletBinding( SupportsShouldProcess = $True, ConfirmImpact = 'High' )]
    [OutputType([Object])]
    Param(
        # The sales order ID
        [Parameter( Mandatory = $True )]
        [Alias('SalesOrder')]
        [int64]$SalesOrderID
    )
    Invoke-HaloPreFlightCheck
    try {
        $ObjectToDelete = Get-HaloSalesOrder -SalesOrderID $SalesOrderID
        if ($ObjectToDelete) {
            if ($PSCmdlet.ShouldProcess("SalesOrder '$($ObjectToDelete.name)')'", 'Delete')) {
                $Resource = "api/salesorder/$($SalesOrderID)"
                $SalesOrderResults = New-HaloDELETERequest -Resource $Resource
                Return $SalesOrderResults
            }
        } else {
            Throw 'Sales Order was not found in Halo to delete.'
        }
    } catch {
        New-HaloError -ErrorRecord $_
    }
}
