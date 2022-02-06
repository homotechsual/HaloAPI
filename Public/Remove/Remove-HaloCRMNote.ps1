function Remove-HaloAction {
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
        $ObjectToDelete = Get-HaloAction -ActionID $ActionID -TicketID $TicketID
        if ($ObjectToDelete) {
            if ($PSCmdlet.ShouldProcess("Action '$($ObjectToDelete.id)' by '$($ObjectToDelete.who)'", 'Delete')) {
                $Resource = "api/actions/$($ActionID)?ticket_id=$($TicketID)"
                $ActionResults = New-HaloDELETERequest -Resource $Resource
                Return $ActionResults
            }
        } else {
            Throw 'Action was not found in Halo to delete.'
        }
    } catch {
        New-HaloError -ErrorRecord $_
    }
}