Function New-HaloWorkflow {
    <#
        .SYNOPSIS
            Creates one or more Workflow(s) via the Halo API.
        .DESCRIPTION
            Function to send a Workflow(s) creation request to the Halo API
        .OUTPUTS
            Outputs an object containing the response from the web request.
    #>
    [CmdletBinding( SupportsShouldProcess = $True )]
    [OutputType([Object[]])]
    Param (
        # Object or array of objects containing properties and values used to create one or more new statuses.
        [Parameter( Mandatory = $True )]
        [Object[]]$Workflow
    )
    Invoke-HaloPreFlightCheck
    try {
        if ($PSCmdlet.ShouldProcess($Workflow -is [Array] ? 'Workflows' : 'Workflow', 'Create')) {
            New-HaloPOSTRequest -Object $Workflow -Endpoint 'Workflow'
        }
    } catch {
        New-HaloError -ErrorRecord $_
    }
}