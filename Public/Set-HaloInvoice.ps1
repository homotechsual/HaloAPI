Function Set-HaloInvoice {
    <#
    .SYNOPSIS
        Updates an invoice via the Halo API.
    .DESCRIPTION
        Function to send an invoice update request to the Halo API
    .OUTPUTS
        Outputs an object containing the response from the web request.
    #>
    [CmdletBinding()]
    Param (
        [Parameter( Mandatory = $True )]
        [PSCustomObject]$Invoice
    )
    Invoke-HaloUpdate -Object $Invoice -Endpoint "invoice" -Update
}