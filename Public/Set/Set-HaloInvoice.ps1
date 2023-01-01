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
        [Object[]]$Invoice,
        # Skip validation checks.
        [Parameter()]
        [Switch]$SkipValidation
    )
    Invoke-HaloPreFlightCheck
    try {
        $ObjectToUpdate = $Invoice | ForEach-Object {
            if ($null -eq $_.id) {
                throw 'Invoice ID is required.'
            }
            $HaloInvoiceParams = @{
                InvoiceId = ($_.id)
            }
            if (-not $SkipValidation) {
                $InvoiceExists = Get-HaloInvoice @HaloInvoiceParams
                if ($InvoiceExists) {
                    Return $True
                } else {
                    Return $False
                }
            } else {
                Write-Verbose 'Skipping validation checks.'
                Return $True
            }
        }
        if ($False -notin $ObjectToUpdate) {
            if ($PSCmdlet.ShouldProcess($Invoice -is [Array] ? 'Invoices' : 'Invoice', 'Update')) {
                New-HaloPOSTRequest -Object $Invoice -Endpoint 'invoice'
            }
        } else {
            Throw 'One or more invoices was not found in Halo to update.'
        }
    } catch {
        New-HaloError -ErrorRecord $_
    }
}