Function New-HaloInvoice {
    <#
        .SYNOPSIS
            Creates an invoice via the Halo API.
        .DESCRIPTION
            Function to send an invoice creation request to the Halo API
        .OUTPUTS
            Outputs an object containing the response from the web request.
    #>
    [CmdletBinding( SupportsShouldProcess = $True )]
    [OutputType([Object])]
    Param (
        # Object containing properties and values used to create a new invoice.
        [Parameter( Mandatory = $True )]
        [Object]$Invoice
    )
    Invoke-HaloPreFlightCheck
    try {
        if ($PSCmdlet.ShouldProcess("Invoice '$($Invoice.invoicenumber)'", 'Create')) {
            New-HaloPOSTRequest -Object $Invoice -Endpoint 'invoice'
        }
    } catch {
        New-HaloError -ErrorRecord $_
    }
}