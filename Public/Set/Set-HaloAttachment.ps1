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
        [PSCustomObject]$Attachment,
        # Skip validation checks.
        [Parameter()]
        [Switch]$SkipValidation
    )
    Invoke-HaloPreFlightCheck
    try {
        if ($null -eq $Attachment.id) {
            throw 'Attachment ID is required.'
        }
        if ($null -eq $Attachment.ticket_id) {
            throw 'Ticket ID is required.'
        }
        if (-not $SkipValidation) {
            $ObjectToUpdate = Get-HaloAttachment -TicketID $Attachment.ticket_id -AttachmentID $Attachment.id
        } else {
            Write-Verbose 'Skipping validation checks.'
            $ObjectToUpdate = $True
        }
        if ($ObjectToUpdate) {
            if ($PSCmdlet.ShouldProcess('Attachment', 'Update')) {
                New-HaloPOSTRequest -Object $Attachment -Endpoint 'attachment'
            }
        } else {
            Throw 'Attachment was not found in Halo to update.'
        }
    } catch {
        New-HaloError -ErrorRecord $_
    }
}