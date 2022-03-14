Function New-HaloAction {
    <#
        .SYNOPSIS
            Creates one or more actions via the Halo API.
        .DESCRIPTION
            Function to send an action creation request to the Halo API
        .OUTPUTS
            Outputs an object containing the response from the web request.
    #>
    [CmdletBinding( SupportsShouldProcess = $True )]
    [OutputType([Object[]])]
    Param (
        # Object or array of objects containing properties and values used to create one or more new actions.
        [Parameter( Mandatory = $True )]
        [Object[]]$Action
    )
    Invoke-HaloPreFlightCheck
    try {
        if ($PSCmdlet.ShouldProcess($Action -is [Array] ? 'Actions' : 'Action', 'Create')) {
            New-HaloPOSTRequest -Object $Action -Endpoint 'actions'
        }
    } catch {
        New-HaloError -ErrorRecord $_
    }
}