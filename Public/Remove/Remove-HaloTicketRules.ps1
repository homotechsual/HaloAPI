function Remove-HaloTicketRules {
    <#
        .SYNOPSIS
           Removes an Rule from the Halo API.
        .DESCRIPTION
            Deletes a specific Rule from Halo.
        .OUTPUTS
            A powershell object containing the response.
    #>
    [cmdletbinding( SupportsShouldProcess = $True, ConfirmImpact = 'High' )]
    [OutputType([Object])]
    Param(
        # The Rule ID
        [Parameter( Mandatory = $True )]
        [alias('Rule_id')]
        [int64]$RuleID
    )
    Invoke-HaloPreFlightCheck
    try {
        $ObjectToDelete = Get-HaloTicketRules -RuleID $RuleID
        if ($ObjectToDelete) {
            if ($PSCmdlet.ShouldProcess(('Rule ''{0}''' -f $ObjectToDelete.value), 'Delete')) {
                $Resource = ('api/TicketRules/{0}' -f $RuleID)
                $ActionResults = New-HaloDELETERequest -Resource $Resource
                Return $ActionResults
            }
        } else {
            Throw 'Rule was not found in Halo to delete.'
        }
    } catch {
        New-HaloError -ErrorRecord $_
    }
}
