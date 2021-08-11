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
    [OutputType([PSCustomObject])]
    Param (
        # Object containing properties and values used to create a new invoice.
        [Parameter( Mandatory = $True )]
        [PSCustomObject]$Invoice
    )
    if ($PSCmdlet.ShouldProcess("Invoice", "Create")) {
        Invoke-HaloUpdate -Object $Invoice -Endpoint "invoice"
    }
}