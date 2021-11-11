Function Set-HaloTeam {
    <#
        .SYNOPSIS
            Updates a team via the Halo API.
        .DESCRIPTION
            Function to send a team update request to the Halo API
        .OUTPUTS
            Outputs an object containing the response from the web request.
    #>
    [CmdletBinding( SupportsShouldProcess = $True )]
    [OutputType([Object])]
    Param (
        # Object containing properties and values used to update an existing team.
        [Parameter( Mandatory = $True, ValueFromPipeline )]
        [Object]$Team
    )
    Invoke-HaloPreFlightCheck
    $CommandName = $MyInvocation.InvocationName
    try {
        $ObjectToUpdate = Get-HaloTeam -TeamID $Team.id
        if ($ObjectToUpdate) {
            if ($PSCmdlet.ShouldProcess("Team '$($ObjectToUpdate.name)'", 'Update')) {
                New-HaloPOSTRequest -Object $Team -Endpoint 'team' -Update
            }
        } else {
            Throw 'Team was not found in Halo to update.'
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