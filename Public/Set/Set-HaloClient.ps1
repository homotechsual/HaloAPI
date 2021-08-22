Function Set-HaloClient {
    <#
        .SYNOPSIS
            Updates a client via the Halo API.
        .DESCRIPTION
            Function to send a client update request to the Halo API
        .OUTPUTS
            Outputs an object containing the response from the web request.
    #> 
    [CmdletBinding( SupportsShouldProcess = $True )]
    [OutputType([Object])]
    Param (
        # Object containing properties and values used to update an existing client.
        [Parameter( Mandatory = $True )]
        [Object]$Client
    )
    Invoke-HaloPreFlightChecks
    $CommandName = $MyInvocation.InvocationName
    try {
        $ObjectToUpdate = Get-HaloClient -ClientID $Client.id
        if ($ObjectToUpdate) { 
            if ($PSCmdlet.ShouldProcess("Client '$($ObjectToUpdate.name)'", 'Update')) {
                New-HaloPOSTRequest -Object $Client -Endpoint 'client' -Update
            }
        } else {
            Throw 'Client was not found in Halo to update.'
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