Function Set-HaloInvoice {
    <#
        .SYNOPSIS
            Updates one or more invoices via the Halo API.
        .DESCRIPTION
            Function to send an invoice update request to the Halo API
        .OUTPUTS
            Outputs an object containing the response from the web request.
    #>
    [CmdletBinding( SupportsShouldProcess = $True )]
    [OutputType([Object[]])]
    Param (
        # Object or array of objects containing properties and values used to update one or more existing invoices.
        [Parameter( Mandatory = $True, ValueFromPipeline )]
        [Object[]]$Invoice
    )
    Invoke-HaloPreFlightCheck
    try {
        $ObjectToUpdate = $False
        ForEach-Object -InputObject $Invoice {
            $HaloInvoiceParams = @{
                InvoiceId = $_.id
            }
            $InvoiceExists = Get-HaloInvoice @HaloInvoiceParams
            if ($InvoiceExists) {
                Set-Variable -Scope 1 -Name 'ObjectToUpdate' -Value $True
            }
        }
        if ($ObjectToUpdate) {
            if ($PSCmdlet.ShouldProcess($Invoice -is [Array] ? 'Invoices' : 'Invoice', 'Update')) {
                New-HaloPOSTRequest -Object $Invoice -Endpoint 'invoice' -Update
            }
        } else {
            Throw 'One or more invoices was not found in Halo to update.'
        }
    } catch {
        New-HaloError -ErrorRecord $_
    }
}