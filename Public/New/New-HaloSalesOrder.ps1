Function New-HaloSalesOrder {
    <#
        .SYNOPSIS
            Creates one or more sales orders via the Halo API.
        .DESCRIPTION
            Function to send a sales order creation request to the Halo API
        .OUTPUTS
            Outputs an object containing the response from the web request.
    #>
    [CmdletBinding( SupportsShouldProcess = $True )]
    [OutputType([Object[]])]
    Param (
        # Object or array of objects containing properties and values used to create one or more new quotations.
        [Parameter( Mandatory = $True )]
        [Object[]]$SalesOrder
    )
    Invoke-HaloPreFlightCheck
    try {
        if ($PSCmdlet.ShouldProcess($SalesOrder -is [Array] ? 'SalesOrders' : 'SalesOrder', 'Create')) {
            New-HaloPOSTRequest -Object $SalesOrder -Endpoint 'salesorder'
        }
    } catch {
        New-HaloError -ErrorRecord $_
    }
}