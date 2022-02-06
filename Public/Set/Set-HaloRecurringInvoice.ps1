Function Set-HaloRecurringInvoice {
    <#
        .SYNOPSIS
            Updates a recurring invoice via the Halo API.
        .DESCRIPTION
            Function to send a recurring invoice update request to the Halo API
        .OUTPUTS
            Outputs an object containing the response from the web request.
    #>
    [CmdletBinding( SupportsShouldProcess = $True )]
    [OutputType([Object])]
    Param (
        # Object containing properties and values used to update an existing invoice.
        [Parameter( Mandatory = $True, ValueFromPipeline )]
        [Object]$RecurringInvoice
    )
    Invoke-HaloPreFlightCheck
    try {
        $ObjectToUpdate = Get-HaloRecurringInvoice -RecurringInvoiceID $RecurringInvoice.id
        if ($ObjectToUpdate) {
            if ($PSCmdlet.ShouldProcess("Invoice '$($ObjectToUpdate.id)'", 'Update')) {
                New-HaloPOSTRequest -Object $RecurringInvoice -Endpoint 'recurringinvoice' -Update
            }
        } else {
            Throw 'Recurring Invoice was not found in Halo to update.'
        }
    } catch {
        New-HaloError -ErrorRecord $_
    }
}