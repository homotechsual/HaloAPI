function Remove-HaloAction {
    <#
        .SYNOPSIS
           Removes an action from the Halo API.
        .DESCRIPTION
            Deletes a specific action from Halo.
        .OUTPUTS
            A powershell object containing the response.
    #>
    [cmdletbinding(SupportsShouldProcess, ConfirmImpact = "High")]
    Param(
        # The Action ID
        [Parameter( Mandatory = $True )]
        [int64]$ActionID,
        # The Ticket ID
        [Parameter( Mandatory = $True )]
        [int64]$TicketID
    )

    try {
        $ObjectToDelete = Get-HaloAction -ActionID $ActionID -TicketID $TicketID
        if ($ObjectToDelete) {
            if ($PSCmdlet.ShouldProcess($ObjectToDelete.note)) {
                $Resource = "api/Actions/$($ActionID)?ticket_id=$($TicketID)"
                $ActionResults = Invoke-HaloRemove -resource $Resource
                Return $ActionResults
            }
        } else {
            Throw "Object was not found in Halo to delete"
        }
    } catch {
        Write-Error "Deleting object failed"
        Write-Verbose "$_"
    }
            
}