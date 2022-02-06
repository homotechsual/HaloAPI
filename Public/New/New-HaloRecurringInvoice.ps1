Function New-HaloRecurringInvoice {
    <#
        .SYNOPSIS
            Creates a recurring invoice via the Halo API.
        .DESCRIPTION
            Function to send a recurring invoice creation request to the Halo API
        .OUTPUTS
            Outputs an object containing the response from the web request.
    #>
    [CmdletBinding( SupportsShouldProcess = $True )]
    [OutputType([Object])]
    Param (
        # Object containing properties and values used to create a new invoice.
        [Parameter( Mandatory = $True )]
        [Object]$RecurringInvoice
    )
    Invoke-HaloPreFlightCheck
    try {
        if ($PSCmdlet.ShouldProcess("Invoice '$($RecurringInvoice.invoicenumber)'", 'Create')) {
            New-HaloPOSTRequest -Object $RecurringInvoice -Endpoint 'recurringinvoice'
        }
    } catch {
        New-HaloError -ErrorRecord $_
    }
}