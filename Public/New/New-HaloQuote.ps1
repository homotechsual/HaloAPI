Function New-HaloQuote {
    <#
        .SYNOPSIS
            Creates a quote via the Halo API.
        .DESCRIPTION
            Function to send a quote creation request to the Halo API
        .OUTPUTS
            Outputs an object containing the response from the web request.
    #>
    [CmdletBinding( SupportsShouldProcess = $True )]
    [OutputType([Object])]
    Param (
        # Object containing properties and values used to create a new quotation.
        [Parameter( Mandatory = $True )]
        [Object]$Quote
    )
    try {
        if ($PSCmdlet.ShouldProcess("Quote '$($Quote.title)'", "Create")) {
            New-HaloPOSTRequest -Object $Quote -Endpoint "quotation"
        }
    } catch {
        Write-Error "Failed to create quote with the Halo API. You'll see more detail if using '-Verbose'"
        Write-Verbose "$_"
    }
}