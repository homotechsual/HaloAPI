Function Remove-HaloQuote {
    <#
        .SYNOPSIS
           Removes a Quote from the Halo API.
        .DESCRIPTION
            Deletes a specific Quote from Halo.
        .OUTPUTS
            A PowerShell object containing the response.
    #>
    [CmdletBinding( SupportsShouldProcess = $True, ConfirmImpact = 'High' )]
    [OutputType([Object])]
    Param(
        # The Quote ID
        [Parameter( Mandatory = $True )]
        [Alias('Quote')]
        [int64]$QuoteID
    )
    Invoke-HaloPreFlightCheck
    try {
        $ObjectToDelete = Get-HaloQuote -QuoteID $QuoteID
        if ($ObjectToDelete) {
            if ($PSCmdlet.ShouldProcess("Quote '$($ObjectToDelete.name)')'", 'Delete')) {
                $Resource = "api/quotation/$($QuoteID)"
                $QuoteResults = New-HaloDELETERequest -Resource $Resource
                Return $QuoteResults
            }
        } else {
            Throw 'Quote was not found in Halo to delete.'
        }
    } catch {
        New-HaloError -ErrorRecord $_
    }
}
