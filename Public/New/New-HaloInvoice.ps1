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
    try {
        if ($PSCmdlet.ShouldProcess("Invoice '$($Invoice.invoicenumber)'", "Create")) {
            New-HaloPOSTRequest -Object $Invoice -Endpoint "invoice"
        }
    } catch {
        Write-Error "Failed to create invoice with the Halo API. You'll see more detail if using '-Verbose'"
        Write-Verbose "$_"
    }
}