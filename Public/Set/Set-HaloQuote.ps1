Function Set-HaloQuote {
    <#
        .SYNOPSIS
            Updates a quote via the Halo API.
        .DESCRIPTION
            Function to send a quote creation update to the Halo API
        .OUTPUTS
            Outputs an object containing the response from the web request.
    #>
    [CmdletBinding( SupportsShouldProcess = $True )]
    [OutputType([Object])]
    Param (
        # Object containing properties and values used to update an existing quotation.
        [Parameter( Mandatory = $True )]
        [Object]$Quote
    )
    try {
        $ObjectToUpdate = Get-HaloQuote -QuoteID $Quote.id
        if ($ObjectToUpdate) {
            if ($PSCmdlet.ShouldProcess("Quotation '$($ObjectToUpdate.title)'", "Update")) {
                New-HaloPOSTRequest -Object $Quote -Endpoint "quotation" -Update
            }
        } else {
            Throw "Quotation was not found in Halo to update."
        }
    } catch {
        Write-Error "Failed to update quotation with the Halo API. You'll see more detail if using '-Verbose'"
        Write-Verbose "$_"
    }
}