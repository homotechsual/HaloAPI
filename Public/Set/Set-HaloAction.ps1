Function Set-HaloAction {
    <#
        .SYNOPSIS
            Updates an action via the Halo API.
        .DESCRIPTION
            Function to send a action update request to the Halo API
        .OUTPUTS
            Outputs an object containing the response from the web request.
    #>
    [CmdletBinding( SupportsShouldProcess = $True )]
    [OutputType([PSCustomObject])]
    Param (
        # Object containing properties and values used to update an existing action.
        [Parameter( Mandatory = $True )]
        [PSCustomObject]$Action
    )
    try {
        $ObjectToUpdate = Get-HaloAction -ActionID $Action.id -TicketID $Action.ticket_id
        if ($ObjectToUpdate) {
            if ($PSCmdlet.ShouldProcess("Action $($ObjectToUpdate.id) by $($ObjectToUpdate.who)", "Update")) {
                New-HaloPOSTRequest -Object $Action -Endpoint "actions" -Update
            }
        } else {
            Throw "Action was not found in Halo to update."
        }
    } catch {
        Write-Error "Failed to update action with the Halo API. You'll see more detail if using '-Verbose'"
        Write-Verbose "$_"
    }
}