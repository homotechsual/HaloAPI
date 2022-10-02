function Restore-HaloTicket {
    <#
        .SYNOPSIS
            Restores a ticket using the Halo API.
        .DESCRIPTION
            Restores a specific ticket or array of tickets from Halo.
        .OUTPUTS
            A powershell object containing the response.
    #>
    [cmdletbinding( SupportsShouldProcess = $True, ConfirmImpact = 'High' )]
    [OutputType([Object])]
    Param(
        # The Ticket id or array of ticket ids.
        [Parameter( Mandatory = $True )]
        [Alias('Ticket')]
        [int64[]]$TicketId
    )
    Invoke-HaloPreFlightCheck
    try {
        $Tickets = ForEach ($Ticket in $TicketId) {
            @{
                id = $Ticket
                _recover = $True
                _validate_updates = $True
            }
        }
        Write-Debug "Tickets object: $($Tickets | Out-String)"
        if ($PSCmdlet.ShouldProcess($Tickets -is [Array] ? 'Tickets' : 'Ticket', 'Restore')) {
            Set-HaloTicket -Ticket $Tickets
        }
    } catch {
        New-HaloError -ErrorRecord $_
    }
}