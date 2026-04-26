function Remove-HaloAction {
    <#
        .SYNOPSIS
           Removes an action from the Halo API.
        .DESCRIPTION
            Deletes a specific action from Halo.
        .OUTPUTS
            A powershell object containing the response.
    #>
    [cmdletbinding( SupportsShouldProcess = $True, ConfirmImpact = 'High' )]
    [OutputType([Object])]
    Param(
        # The Action ID
        [Parameter( Mandatory, ParameterSetName = 'Single' )]
        [int64]$ActionID,
        # The Ticket ID
        [Parameter( Mandatory, ParameterSetName = 'Single' )]
        [int64]$TicketID,
        # Object containing action id and ticket id for batch processing.
        [Parameter( Mandatory, ParameterSetName = 'Batch')]
        [Object]$Action
    )
    Invoke-HaloPreFlightCheck
    try {
        if ($Action) {
            $ActionID = $Action.Id
            $TicketID = $Action.TicketId
        }
        $ObjectToDelete = Get-HaloAction -ActionID $ActionID -TicketID $TicketID
        if ($ObjectToDelete) {
            if ($PSCmdlet.ShouldProcess(('Action ''{0}'' by ''{1}''' -f $ObjectToDelete.id, $ObjectToDelete.who), 'Delete')) {
                $Resource = ('api/actions/{0}?ticket_id={1}' -f $ActionID, $TicketID)
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
