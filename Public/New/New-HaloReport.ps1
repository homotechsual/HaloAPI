Function New-HaloReport {
    <#
        .SYNOPSIS
            Creates a report via the Halo API.
        .DESCRIPTION
            Function to send a report creation request to the Halo API
        .OUTPUTS
            Outputs an object containing the response from the web request.
    #>
    [CmdletBinding( SupportsShouldProcess = $True )]
    [OutputType([Object])]
    Param (
        # Object containing properties and values used to create a new report.
        [Parameter( Mandatory = $True )]
        [Object]$Report
    )
    Invoke-HaloPreFlightCheck
    $CommandName = $MyInvocation.InvocationName
    try {
        if ($PSCmdlet.ShouldProcess("Report '$($Report.name)'", 'Create')) {
            New-HaloPOSTRequest -Object $Report -Endpoint 'report'
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