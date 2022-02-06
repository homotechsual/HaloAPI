Function Set-HaloInvoice {
    <#
        .SYNOPSIS
            Updates an invoice via the Halo API.
        .DESCRIPTION
            Function to send an invoice update request to the Halo API
        .OUTPUTS
            Outputs an object containing the response from the web request.
    #>
    [CmdletBinding( SupportsShouldProcess = $True )]
    [OutputType([Object])]
    Param (
        # Object containing properties and values used to update an existing invoice.
        [Parameter( Mandatory = $True, ValueFromPipeline )]
        [Object]$Invoice
    )
    Invoke-HaloPreFlightCheck
    try {
        $ObjectToUpdate = Get-HaloInvoice -InvoiceID $Invoice.id
        if ($ObjectToUpdate) {
            if ($PSCmdlet.ShouldProcess("Invoice '$($ObjectToUpdate.invoicenumber)'", 'Update')) {
                New-HaloPOSTRequest -Object $Invoice -Endpoint 'invoice' -Update
            }
        } else {
            Throw 'Invoice was not found in Halo to update.'
        }
    } catch {
        New-HaloError -ErrorRecord $_
    }
}