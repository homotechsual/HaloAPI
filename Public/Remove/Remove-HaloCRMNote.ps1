function Remove-HaloCRMNote {
    <#
        .SYNOPSIS
           Removes a CRM note from the Halo API.
        .DESCRIPTION
            Deletes a specific CRM note from Halo.
        .OUTPUTS
            A powershell object containing the response.
    #>
    [cmdletbinding( SupportsShouldProcess = $True, ConfirmImpact = 'High' )]
    [OutputType([Object])]
    Param(
        # The CRN note ID
        [Parameter( Mandatory = $True )]
        [int64]$CRMNoteID,
        # The Ticket ID
        [Parameter( Mandatory = $True )]
        [int64]$TicketID
    )
    Invoke-HaloPreFlightCheck
    try {
        $ObjectToDelete = Get-HaloAction -ActionID $CRMNoteID -TicketID $TicketID
        if ($ObjectToDelete) {
            if ($PSCmdlet.ShouldProcess("CRM Note '$($ObjectToDelete.id)'", 'Delete')) {
                $Resource = "api/actions/$($CRMNoteID)?ticket_id=$($TicketID)"
                $CRMNoteResults = New-HaloDELETERequest -Resource $Resource
                Return $CRMNoteResults
            }
        } else {
            Throw 'CRM Note was not found in Halo to delete.'
        }
    } catch {
        New-HaloError -ErrorRecord $_
    }
}