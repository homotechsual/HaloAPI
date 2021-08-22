Function New-HaloContract {
    <#
        .SYNOPSIS
            Creates a contract via the Halo API.
        .DESCRIPTION
            Function to send a contract creation request to the Halo API
        .OUTPUTS
            Outputs an object containing the response from the web request.
    #>
    [CmdletBinding( SupportsShouldProcess = $True )]
    [OutputType([Object])]
    Param (
        # Object containing properties and values used to create a new contract.
        [Parameter( Mandatory = $True )]
        [Object]$Contract
    )
    Invoke-HaloPreFlightChecks
    $CommandName = $MyInvocation.InvocationName
    try {
        if ($PSCmdlet.ShouldProcess("Contract '$($Contract.ref)'", 'Create')) {
            New-HaloPOSTRequest -Object $Contract -Endpoint 'clientcontract'
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