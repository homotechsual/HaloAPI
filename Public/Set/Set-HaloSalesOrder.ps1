Function Set-HaloSalesOrder {
    <#
        .SYNOPSIS
            Updates a sales order via the Halo API.
        .DESCRIPTION
            Function to send a sales order update request to the Halo API.
        .OUTPUTS
            Outputs an object containing the response from the web request.
    #>
    [CmdletBinding( SupportsShouldProcess = $True )]
    [OutputType([Object])]
    Param (
        # Object containing properties and values used to update an existing sales order.
        [Parameter( Mandatory = $True, ValueFromPipeline )]
        [Object]$SalesOrder,
        # Skip validation checks.
        [Parameter()]
        [Switch]$SkipValidation
    )
    Invoke-HaloPreFlightCheck
    try {
        if ($null -eq $SalesOrder.id) {
            throw 'Sales order ID is required.'
        }
        if (-not $SkipValidation) {
            $ObjectToUpdate = Get-HaloSalesOrder -SalesOrderID $SalesOrder.id
        } else {
            Write-Verbose 'Skipping validation checks.'
            $ObjectToUpdate = $True
        }
        if ($ObjectToUpdate) {
            if ($PSCmdlet.ShouldProcess('Sales Order', 'Update')) {
                New-HaloPOSTRequest -Object $SalesOrder -Endpoint 'salesorder'
            }
        } else {
            Throw 'Sales Order was not found in Halo to update.'
        }
    } catch {
        New-HaloError -ErrorRecord $_
    }
}
