Function Set-HaloAttachment {
    <#
        .SYNOPSIS
            Updates an attachment via the Halo API.
        .DESCRIPTION
            Function to send an attachment update request to the Halo API
        .OUTPUTS
            Outputs an object containing the response from the web request.
    #>
    [CmdletBinding( SupportsShouldProcess = $True )]
    [OutputType([PSCustomObject])]
    Param (
        # Object containing properties and values used to update an existing attachment.
        [Parameter( Mandatory = $True, ValueFromPipeline )]
        [PSCustomObject]$Attachment
    )
    Invoke-HaloPreFlightCheck
    $CommandName = $MyInvocation.InvocationName
    try {
        $ObjectToUpdate = Get-HaloAttachment -TicketID $Attachment.ticket_id -AttachmentID $Attachment.id
        if ($ObjectToUpdate) {
            if ($PSCmdlet.ShouldProcess("Attachment '$($ObjectToUpdate.filename)'", 'Update')) {
                New-HaloPOSTRequest -Object $Attachment -Endpoint 'attachment' -Update
            }
        } else {
            Throw 'Attachment was not found in Halo to update.'
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