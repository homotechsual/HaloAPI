Function Set-HaloAction {
    <#
        .SYNOPSIS
            Updates one or more actions via the Halo API.
        .DESCRIPTION
            Function to send a action update request to the Halo API
        .OUTPUTS
            Outputs an object containing the response from the web request.
    #>
    [CmdletBinding( SupportsShouldProcess = $True )]
    [OutputType([Object[]])]
    Param (
        # Object or array of objects containing properties and values used to update one or more existing actions.
        [Parameter( Mandatory = $True, ValueFromPipeline = $True )]
        [Object[]]$Action
    )
    Invoke-HaloPreFlightCheck
    try {
        $ObjectToUpdate = $False
        ForEach-Object -InputObject $Action {
            $HaloActionParams = @{
                ActionID = $_.id
                TicketID = [int]$_.ticket_id
            }
            $ActionExists = Get-HaloAction @HaloActionParams
            if ($ActionExists) {
                Set-Variable -Scope 1 -Name 'ObjectToUpdate' -Value $True
            }
        }
        if ($ObjectToUpdate) {
            if ($PSCmdlet.ShouldProcess($Action -is [Array] ? 'Actions' : 'Action', 'Update')) {
                New-HaloPOSTRequest -Object $Action -Endpoint 'actions' -Update
            }
        } else {
            Throw 'One or more actions was not found in Halo to update.'
        }
    } catch {
        New-HaloError -ErrorRecord $_
    }
}