Function New-HaloAgent {
    <#
    .SYNOPSIS
        Creates an agent via the Halo API.
    .DESCRIPTION
        Function to send an agent creation request to the Halo API
    .OUTPUTS
        Outputs an object containing the response from the web request.
    #>
    [CmdletBinding()]
    Param (
        # Object containing properties and values used to create a new agent.
        [Parameter( Mandatory = $True )]
        [PSCustomObject]$Agent
    )
    Invoke-HaloUpdate -Object $Agent -Endpoint "agent"
}