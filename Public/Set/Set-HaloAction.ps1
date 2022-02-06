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
        [Parameter( Mandatory = $True, ValueFromPipeline = $True )]
        [PSCustomObject]$Action
    )
    Invoke-HaloPreFlightCheck
    try {
        $HaloActionParams = @{
            ActionID = $Action.id
            TicketID = [int]$Action.ticket_id
        }
        $ObjectToUpdate = Get-HaloAction @HaloActionParams
        if ($ObjectToUpdate) {
            if ($PSCmdlet.ShouldProcess("Action $($ObjectToUpdate.id) by $($ObjectToUpdate.who)", 'Update')) {
                New-HaloPOSTRequest -Object $Action -Endpoint 'actions' -Update
            }
        } else {
            Throw 'Action was not found in Halo to update.'
        }
    } catch {
        New-HaloError -ErrorRecord $_
    }
}