Function New-HaloQuote {
    <#
        .SYNOPSIS
            Creates one or more quotes via the Halo API.
        .DESCRIPTION
            Function to send a quote creation request to the Halo API
        .OUTPUTS
            Outputs an object containing the response from the web request.
    #>
    [CmdletBinding( SupportsShouldProcess = $True )]
    [OutputType([Object[]])]
    Param (
        # Object or array of objects containing properties and values used to create one or more new quotations.
        [Parameter( Mandatory = $True )]
        [Object[]]$Quote
    )
    Invoke-HaloPreFlightCheck
    try {
        if ($PSCmdlet.ShouldProcess($Quote -is [Array] ? 'Quotes' : 'Quote', 'Create')) {
            New-HaloPOSTRequest -Object $Quote -Endpoint 'quotation'
        }
    } catch {
        New-HaloError -ErrorRecord $_
    }
}