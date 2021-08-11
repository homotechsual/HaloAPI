Function Set-HaloQuote {
    <#
    .SYNOPSIS
        Updates a quote via the Halo API.
    .DESCRIPTION
        Function to send a quote creation update to the Halo API
    .OUTPUTS
        Outputs an object containing the response from the web request.
    #>
    [CmdletBinding()]
    Param (
        # Object containing properties and values used to update an existing quotation.
        [Parameter( Mandatory = $True )]
        [PSCustomObject]$Quote
    )
    Invoke-HaloUpdate -Object $Quote -Endpoint "quotation" -Update
}