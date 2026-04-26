function New-HaloSalesOrder {
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
    param (
        # Object or array of objects containing properties and values used to create one or more new sales orders.
        [Parameter( Mandatory = $True )]
        [Object[]]$SalesOrder
    )
    Invoke-HaloPreFlightCheck
    try {
        if ($PSCmdlet.ShouldProcess($SalesOrder -is [Array] ? 'Sales Orders' : 'Sales Order', 'Create')) {
            $Results = New-HaloPOSTRequest -Object $SalesOrder -Endpoint 'salesorder'
            return $Results
        }
    } catch {
        New-HaloError -ErrorRecord $_
    }
}
