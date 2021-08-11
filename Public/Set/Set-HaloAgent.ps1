Function Set-HaloAgent {
    <#
        .SYNOPSIS
            Updates an agent via the Halo API.
        .DESCRIPTION
            Function to send an agent update request to the Halo API
        .OUTPUTS
            Outputs an object containing the response from the web request.
    #>
    [CmdletBinding( SupportsShouldProcess = $True )]
    [OutputType([PSCustomObject])]
    Param (
        # Object containing properties and values used to update an existing agent.
        [Parameter( Mandatory = $True )]
        [PSCustomObject]$Agent
    )
    if ($PSCmdlet.ShouldProcess("Agent", "Update")) {
        Invoke-HaloUpdate -Object $Agent -Endpoint "agent" -Update
    }
}