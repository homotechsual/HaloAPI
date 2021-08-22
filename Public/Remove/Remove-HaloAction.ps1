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
        [Parameter( Mandatory = $True )]
        [int64]$ActionID,
        # The Ticket ID
        [Parameter( Mandatory = $True )]
        [int64]$TicketID
    )
    Invoke-HaloPreFlightChecks
    $CommandName = $MyInvocation.InvocationName
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