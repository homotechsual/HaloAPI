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
    [OutputType([PSCustomObject])]
    Param (
        # Object containing properties and values used to update an existing invoice.
        [Parameter( Mandatory = $True )]
        [PSCustomObject]$Invoice
    )
    if ($PSCmdlet.ShouldProcess("Invoice", "Update")) {
        Invoke-HaloUpdate -Object $Invoice -Endpoint "invoice" -Update
    }
}