Function Set-HaloAgent {
    <#
        .SYNOPSIS
            Updates one or more agents via the Halo API.
        .DESCRIPTION
            Function to send an agent update request to the Halo API
        .OUTPUTS
            Outputs an object containing the response from the web request.
    #>
    [CmdletBinding( SupportsShouldProcess = $True )]
    [OutputType([Object[]])]
    Param (
        # Object or array of objects containing properties and values used to update one or more existing agents.
        [Parameter( Mandatory = $True, ValueFromPipeline )]
        [Object[]]$Agent,
        # Skip validation checks.
        [Parameter()]
        [Switch]$SkipValidation
    )
    Invoke-HaloPreFlightCheck
    try {
        $ObjectToUpdate = $Agent | ForEach-Object {
            if ($null -eq $_.id) {
                throw 'Agent ID is required.'
            }
            $HaloAgentParams = @{
                AgentId = $_.id
            }
            if (-not $SkipValidation) {
                $AgentExists = Get-HaloAgent @HaloAgentParams
                if ($AgentExists) {
                    Return $True
                } else {
                    Return $False
                }
            } else {
                Write-Verbose 'Skipping validation checks.'
                Return $True
            }
        }
        if ($False -notin $ObjectToUpdate) {
            if ($PSCmdlet.ShouldProcess($Agent -is [Array] ? 'Agents' : 'Agent', 'Update')) {
                New-HaloPOSTRequest -Object $Agent -Endpoint 'agent'
            }
        } else {
            Throw 'One or more agents was not found in Halo to update.'
        }
    } catch {
        New-HaloError -ErrorRecord $_
    }
}