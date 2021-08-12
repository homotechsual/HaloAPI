Function New-HaloAgent {
    <#
        .SYNOPSIS
            Creates an agent via the Halo API.
        .DESCRIPTION
            Function to send an agent creation request to the Halo API
        .OUTPUTS
            Outputs an object containing the response from the web request.
    #>
    [CmdletBinding( SupportsShouldProcess = $True )]
    [OutputType([Object])]
    Param (
        # Object containing properties and values used to create a new agent.
        [Parameter( Mandatory = $True )]
        [Object]$Agent
    )
    try {
        if ($PSCmdlet.ShouldProcess("Agent '$($Agent.name)'", "Create")) {
            New-HaloPOSTRequest -Object $Agent -Endpoint "agent"
        }
    } catch {
        Write-Error "Failed to create agent with the Halo API. You'll see more detail if using '-Verbose'"
        Write-Verbose "$_"
    }
}