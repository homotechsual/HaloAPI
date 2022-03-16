function Remove-HaloAgent {
    <#
        .SYNOPSIS
           Removes an agent from the Halo API.
        .DESCRIPTION
            Deletes a specific agent from Halo.
        .OUTPUTS
            A powershell object containing the response.
    #>
    [cmdletbinding( SupportsShouldProcess = $True, ConfirmImpact = 'High' )]
    [OutputType([Object])]
    Param(
        # The agent ID
        [Parameter( Mandatory = $True )]
        [int64]$AgentId
    )
    Invoke-HaloPreFlightCheck
    try {
        $ObjectToDelete = Get-HaloAgent -AgentId $AgentId
        if ($ObjectToDelete) {
            if ($PSCmdlet.ShouldProcess("Agent '$($ObjectToDelete.name)'", 'Delete')) {
                $Resource = "api/agent/$($AgentId)"
                $ActionResults = New-HaloDELETERequest -Resource $Resource
                Return $ActionResults
            }
        } else {
            Throw 'Action was not found in Halo to delete.'
        }
    } catch {
        New-HaloError -ErrorRecord $_
    }
}