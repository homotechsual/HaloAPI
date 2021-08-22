Function Set-HaloContract {
    <#
        .SYNOPSIS
            Updates a contract via the Halo API.
        .DESCRIPTION
            Function to send a contract update request to the Halo API
        .OUTPUTS
            Outputs an object containing the response from the web request.
    #>
    [CmdletBinding( SupportsShouldProcess = $True )]
    [OutputType([Object])]
    Param (
        # Object containing properties and values used to update an existing contract.
        [Parameter( Mandatory = $True )]
        [Object]$Contract
    )
    Invoke-HaloPreFlightChecks
    $CommandName = $MyInvocation.InvocationName
    try {
        $ObjectToUpdate = Get-HaloContract -ContractID $Contract.id
        if ($ObjectToUpdate) {
            if ($PSCmdlet.ShouldProcess("Contract '$($ObjectToUpdate.ref)'", 'Update')) {
                New-HaloPOSTRequest -Object $Contract -Endpoint 'clientcontract' -Update
            }
        } else {
            Throw 'Contract was not found in Halo to update.'
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