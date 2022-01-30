Function Set-HaloFAQList {
    <#
        .SYNOPSIS
            Updates a FAQ List via the Halo API.
        .DESCRIPTION
            Function to send an FAQ List update request to the Halo API
        .OUTPUTS
            Outputs an object containing the response from the web request.
    #>
    [CmdletBinding( SupportsShouldProcess = $True )]
    [OutputType([Object])]
    Param (
        # Object containing properties and values used to update an existing knowedgebase article.
        [Parameter( Mandatory = $True, ValueFromPipeline )]
        [Object]$FAQList
    )
    Invoke-HaloPreFlightCheck
    $CommandName = $MyInvocation.InvocationName
    try {
        $ObjectToUpdate = Get-HaloFAQList -FAQListID $FAQList.id
        if ($ObjectToUpdate) {
            if ($PSCmdlet.ShouldProcess("FAQ List '$($ObjectToUpdate.name)'", 'Update')) {
                New-HaloPOSTRequest -Object $FAQList -Endpoint 'FAQLists' -Update
            }
        } else {
            Throw 'FAQ List was not found in Halo to update.'
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