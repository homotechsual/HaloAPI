Function New-HaloInvoice {
    <#
        .SYNOPSIS
            Creates one or more invoices via the Halo API.
        .DESCRIPTION
            Function to send an invoice creation request to the Halo API
        .OUTPUTS
            Outputs an object containing the response from the web request.
    #>
    [CmdletBinding( SupportsShouldProcess = $True )]
    [OutputType([Object[]])]
    Param (
        # Object or array of objects containing properties and values used to create one or more new invoices.
        [Parameter( Mandatory = $True )]
        [Object[]]$Invoice
    )
    Invoke-HaloPreFlightCheck
    try {
        if ($PSCmdlet.ShouldProcess($Invoice -is [Array] ? 'Invoices' : 'Invoice', 'Create')) {
            New-HaloPOSTRequest -Object $Invoice -Endpoint 'invoice'
        }
    } catch {
        New-HaloError -ErrorRecord $_
    }
}