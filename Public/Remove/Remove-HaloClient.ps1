function Remove-HaloClient {
    <#
        .SYNOPSIS
           Removes a client from the Halo API.
        .DESCRIPTION
            Deletes a specific client from Halo.
        .OUTPUTS
            A powershell object containing the response.
    #>
    [cmdletbinding( SupportsShouldProcess = $True, ConfirmImpact = 'High' )]
    [OutputType([Object])]
    Param(
        # The client ID
        [Parameter( Mandatory = $True )]
        [int64]$ClientID
    )
    Invoke-HaloPreFlightChecks
    $CommandName = $MyInvocation.InvocationName
    try {
        $ObjectToDelete = Get-HaloClient -ClientID $ClientID
        if ($ObjectToDelete) {
            if ($PSCmdlet.ShouldProcess("Client '$($ObjectToDelete.summary)')'", 'Delete')) {
                $Resource = "api/client/$($ClientID)"
                $ClientResults = New-HaloDELETERequest -Resource $Resource
                Return $ClientResults
            }
        } else {
            Throw 'Client was not found in Halo to delete.'
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