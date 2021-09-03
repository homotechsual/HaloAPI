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
    [OutputType([Object])]
    Param (
        # Object containing properties and values used to update an existing agent.
        [Parameter( Mandatory = $True, ValueFromPipeline )]
        [Object]$Agent
    )
    Invoke-HaloPreFlightCheck
    $CommandName = $MyInvocation.InvocationName
    try {
        $ObjectToUpdate = Get-HaloAgent -AgentId $Agent.id -IncludeDisabled
        if ($ObjectToUpdate) {
            if ($PSCmdlet.ShouldProcess("Agent $($ObjectToUpdate.name)", 'Update')) {
                New-HaloPOSTRequest -Object $Agent -Endpoint 'agent' -Update
            }
        } else {
            Throw 'Agent was not found in Halo to update.'
        }
    } catch {
        $Command = $CommandName -Replace '-', ''
        $ErrorRecord = @{
            ExceptionType = 'System.Exception'
            ErrorMessage = "$($CommandName) failed."
            InnerException = $_.Exception
            ErrorID = "Halo$($Command)CommandFailed"
            ErrorCategory = 'ReadError'
            TargetObject = $_.TargetObject
            ErrorDetails = $_.ErrorDetails
            BubbleUpDetails = $False
        }
        $CommandError = New-HaloErrorRecord @ErrorRecord
        $PSCmdlet.ThrowTerminatingError($CommandError)
    }
}