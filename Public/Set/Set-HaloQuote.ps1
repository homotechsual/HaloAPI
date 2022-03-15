Function Set-HaloQuote {
    <#
        .SYNOPSIS
            Updates one or more quotes via the Halo API.
        .DESCRIPTION
            Function to send a quote creation update to the Halo API
        .OUTPUTS
            Outputs an object containing the response from the web request.
    #>
    [CmdletBinding( SupportsShouldProcess = $True )]
    [OutputType([Object[]])]
    Param (
        # Object or array of objects containing properties and values used to update one or more existing quotations.
        [Parameter( Mandatory = $True, ValueFromPipeline )]
        [Object[]]$Quote
    )
    Invoke-HaloPreFlightCheck
    try {
        $ObjectToUpdate = ForEach-Object -InputObject $Quote {
            $HaloQuoteParams = @{
                QuoteId = $_.id
            }
            $QuoteExists = Get-HaloQuote @HaloQuoteParams
            if ($QuoteExists) {
                Return $True
            } else {
                Return $False
            }
        }
        if ($False -notin $ObjectToUpdate) {
            if ($PSCmdlet.ShouldProcess($Quote -is [Array] ? 'Quotations' : 'Quotation', 'Update')) {
                New-HaloPOSTRequest -Object $Quote -Endpoint 'quotation' -Update
            }
        } else {
            Throw 'One or more quotations was not found in Halo to update.'
        }
    } catch {
        New-HaloError -ErrorRecord $_
    }
}