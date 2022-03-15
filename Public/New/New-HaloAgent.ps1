Function New-HaloAgent {
    <#
        .SYNOPSIS
            Creates one or more agents via the Halo API.
        .DESCRIPTION
            Function to send an agent creation request to the Halo API
        .OUTPUTS
            Outputs an object containing the response from the web request.
    #>
    [CmdletBinding( SupportsShouldProcess = $True )]
    [OutputType([Object[]])]
    Param (
        # Object or array of objects containing properties and values used to create one or more new agents.
        [Parameter( Mandatory = $True )]
        [Object[]]$Agent
    )
    Invoke-HaloPreFlightCheck
    try {
        if ($PSCmdlet.ShouldProcess($Agent -is [Array] ? 'Agents' : 'Agent', 'Create')) {
            New-HaloPOSTRequest -Object $Agent -Endpoint 'agent'
        }
    } catch {
        New-HaloError -ErrorRecord $_
    }
}