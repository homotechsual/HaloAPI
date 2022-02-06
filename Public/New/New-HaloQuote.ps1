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
    Invoke-HaloPreFlightCheck
    try {
        if ($PSCmdlet.ShouldProcess("Quote '$($Quote.title)'", 'Create')) {
            New-HaloPOSTRequest -Object $Quote -Endpoint 'quotation'
        }
    } catch {
        New-HaloError -ErrorRecord $_
    }
}