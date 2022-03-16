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
    try {
        if ($null -eq $Attachment.id) {
            throw 'Attachment ID is required.'
        }
        if ($null -eq $Attachment.ticket_id) {
            throw 'Ticket ID is required.'
        }
        $ObjectToUpdate = Get-HaloAttachment -TicketID $Attachment.ticket_id -AttachmentID $Attachment.id
        if ($ObjectToUpdate) {
            if ($PSCmdlet.ShouldProcess("Attachment '$($ObjectToUpdate.filename)'", 'Update')) {
                New-HaloPOSTRequest -Object $Attachment -Endpoint 'attachment'
            }
        } else {
            Throw 'Attachment was not found in Halo to update.'
        }
    } catch {
        New-HaloError -ErrorRecord $_
    }
}