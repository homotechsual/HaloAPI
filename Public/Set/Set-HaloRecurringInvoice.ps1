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
        [Object]$RecurringInvoice,
        # Skip validation checks.
        [Parameter()]
        [Switch]$SkipValidation
    )
    Invoke-HaloPreFlightCheck
    try {
        if ($null -eq $RecurringInvoice.id) {
            throw 'Recurring invoice ID is required.'
        }
        if (-not $SkipValidation) {
            $ObjectToUpdate = Get-HaloRecurringInvoice -RecurringInvoiceID $RecurringInvoice.id
        } else {
            Write-Verbose 'Skipping validation checks.'
            $ObjectToUpdate = $True
        }
        if ($ObjectToUpdate) {
            if ($PSCmdlet.ShouldProcess('Invoice', 'Update')) {
                New-HaloPOSTRequest -Object $RecurringInvoice -Endpoint 'recurringinvoice'
            }
        } else {
            Throw 'Recurring Invoice was not found in Halo to update.'
        }
    } catch {
        New-HaloError -ErrorRecord $_
    }
}