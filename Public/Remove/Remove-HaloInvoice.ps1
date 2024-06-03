Function Remove-HaloInvoice {
    <#
        .SYNOPSIS
           Removes a Invoice from the Halo API.
        .DESCRIPTION
            Deletes a specific Invoice from Halo.
        .OUTPUTS
            A PowerShell object containing the response.
    #>
    [CmdletBinding( SupportsShouldProcess = $True, ConfirmImpact = 'High' )]
    [OutputType([Object])]
    Param(
        # The Invoice ID
        [Parameter( Mandatory = $True )]
        [Alias('Invoice')]
        [int64]$InvoiceID
    )
    Invoke-HaloPreFlightCheck
    try {
        $ObjectToDelete = Get-HaloInvoice -InvoiceID $InvoiceID
        if ($ObjectToDelete) {
            if ($PSCmdlet.ShouldProcess("Invoice '$($ObjectToDelete.name)')'", 'Delete')) {
                $Resource = "api/Invoice/$($InvoiceID)"
                $InvoiceResults = New-HaloDELETERequest -Resource $Resource
                Return $InvoiceResults
            }
        } else {
            Throw 'Invoice was not found in Halo to delete.'
        }
    } catch {
        New-HaloError -ErrorRecord $_
    }
}
