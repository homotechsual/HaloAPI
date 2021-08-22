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
    Invoke-HaloPreFlightChecks
    $CommandName = $MyInvocation.InvocationName
    try {
        $ObjectToUpdate = Get-HaloQuote -QuoteID $Quote.id
        if ($ObjectToUpdate) {
            if ($PSCmdlet.ShouldProcess("Quotation '$($ObjectToUpdate.title)'", 'Update')) {
                New-HaloPOSTRequest -Object $Quote -Endpoint 'quotation' -Update
            }
        } else {
            Throw 'Quotation was not found in Halo to update.'
        }
    } catch {
        $Command = $CommandName -Replace '-', ''
        $ErrorRecord = @{
            ExceptionType = 'System.Exception'
            ErrorMessage = "$($CommandName) failed."
            InnerException = $_.Exception
            ErrorID = "Halo$($Command)CommandFailed"
            ErrorCategory = 'ReadError'
            TargetObject = $_.TargetObject
            ErrorDetails = $_.ErrorDetails
            BubbleUpDetails = $False
        }
        $CommandError = New-HaloErrorRecord @ErrorRecord
        $PSCmdlet.ThrowTerminatingError($CommandError)
    }
}