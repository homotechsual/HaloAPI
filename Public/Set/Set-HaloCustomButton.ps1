Function Set-HaloCustomButton {
    <#
        .SYNOPSIS
            Updates a custom button via the Halo API.
        .DESCRIPTION
            Function to send a custom button update request to the Halo API
        .OUTPUTS
            Outputs an object containing the response from the web request.
    #>
    [CmdletBinding( SupportsShouldProcess = $True )]
    [OutputType([Object])]
    Param (
        # Object containing properties and values used to update an existing contract.
        [Parameter( Mandatory = $True )]
        [Object]$CustomButton
    )
    Invoke-HaloPreFlightChecks
    $CommandName = $MyInvocation.InvocationName
    try {
        $ObjectToUpdate = Get-HaloCustomButton -CustomButtonID $CustomButton.id
        if ($ObjectToUpdate) {
            if ($PSCmdlet.ShouldProcess("Custom Button '$($ObjectToUpdate.name)'", 'Update')) {
                New-HaloPOSTRequest -Object $CustomButton -Endpoint 'custombutton' -Update
            }
        } else {
            Throw 'Custom button was not found in Halo to update.'
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