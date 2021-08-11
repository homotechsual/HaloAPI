Function New-HaloQuote {
    <#
    .SYNOPSIS
        Creates a quote via the Halo API.
    .DESCRIPTION
        Function to send a quote creation request to the Halo API
    .OUTPUTS
        Outputs an object containing the response from the web request.
    #>
    [CmdletBinding()]
    Param (
        # Object containing properties and values used to create a new quotation.
        [Parameter( Mandatory = $True )]
        [PSCustomObject]$Quote
    )
    Invoke-HaloUpdate -Object $Quote -Endpoint "quotation"
}