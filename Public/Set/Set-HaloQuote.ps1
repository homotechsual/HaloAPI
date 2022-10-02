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
        [Object[]]$Quote,
        # Skip validation checks.
        [Parameter()]
        [Switch]$SkipValidation
    )
    Invoke-HaloPreFlightCheck
    try {
        $ObjectToUpdate = $Quote | ForEach-Object {
            if ($null -eq $_.id) {
                throw 'Quote ID is required.'
            }
            $HaloQuoteParams = @{
                QuoteId = $_.id
            }
            if (-not $SkipValidation) {
                $QuoteExists = Get-HaloQuote @HaloQuoteParams
                if ($QuoteExists) {
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
            if ($PSCmdlet.ShouldProcess($Quote -is [Array] ? 'Quotations' : 'Quotation', 'Update')) {
                New-HaloPOSTRequest -Object $Quote -Endpoint 'quotation'
            }
        } else {
            Throw 'One or more quotations was not found in Halo to update.'
        }
    } catch {
        New-HaloError -ErrorRecord $_
    }
}