Function New-HaloAction {
    <#
        .SYNOPSIS
            Creates an action via the Halo API.
        .DESCRIPTION
            Function to send an action creation request to the Halo API
        .OUTPUTS
            Outputs an object containing the response from the web request.
    #>
    [CmdletBinding( SupportsShouldProcess = $True )]
    [OutputType([Object])]
    Param (
        # Object containing properties and values used to create a new action.
        [Parameter( Mandatory = $True )]
        [Object]$Action
    )
    Invoke-HaloPreFlightCheck
    try {
        if ($PSCmdlet.ShouldProcess("Action by '$($Action.who)'", 'Create')) {
            New-HaloPOSTRequest -Object $Action -Endpoint 'actions'
        }
    } catch {
        New-HaloError -ErrorRecord $_
    }
}