Function New-HaloRecurringInvoiceBatch {
    <#
        .SYNOPSIS
            Creates multiple recurring invoices via the Halo API.
        .DESCRIPTION
            Function to send a batch of recurring invoice creation requests to the Halo API
        .OUTPUTS
            Outputs an object containing the responses from the web requests.
    #>
    [CmdletBinding( SupportsShouldProcess = $True )]
    [OutputType([Object[]])]
    Param (
        # Array of objects containing properties and values used to create one or more new recurring invoices.
        [Parameter( Mandatory = $True )]
        [Array[]]$RecurringInvoices,
        # How many objects to process at once before delaying. Default value is 100.
        [Int32]$BatchSize,
        # How long to wait between batch runs. Default value is 1 second.
        [Int32]$BatchWait
    )
    Invoke-HaloPreFlightCheck
    try {
        if ($PSCmdlet.ShouldProcess('Recurring Invoices', 'Create')) {
            if ($RecurringInvoices -is [Array]) {
                $BatchParams = @{
                    BatchInput = $RecurringInvoices
                    EntityType = 'RecurringInvoice'
                    Operation = 'New'
                }
                if ($BatchSize) {
                    $BatchParams.Size = $BatchSize
                }
                if ($BatchWait) {
                    $BatchParams.Wait = $BatchWait
                }
                $BatchResults = Invoke-HaloBatchProcessor @BatchParams
                Return $BatchResults
            } else {
                throw 'New-HaloInvoiceBatch requires an array of recurring invoices to create.'
            }  
        }
    } catch {
        New-HaloError -ErrorRecord $_
    }
}