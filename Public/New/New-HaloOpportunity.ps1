Function New-HaloOpportunity {
    <#
        .SYNOPSIS
            Creates an opportunity via the Halo API.
        .DESCRIPTION
            Function to send an opportunity creation request to the Halo API
        .OUTPUTS
            Outputs an object containing the response from the web request.
    #>
    [CmdletBinding( SupportsShouldProcess = $True )]
    [OutputType([Object])]
    Param (
        # Object containing properties and values used to create a new opportunity.
        [Parameter( Mandatory = $True )]
        [Object]$Opportunity
    )
    Invoke-HaloPreFlightCheck
    $CommandName = $MyInvocation.InvocationName
    try {
        if ($PSCmdlet.ShouldProcess("Opportunity '$($Opportunity.summary)'", 'Create')) {
            New-HaloPOSTRequest -Object $Opportunity -Endpoint 'opportunities'
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