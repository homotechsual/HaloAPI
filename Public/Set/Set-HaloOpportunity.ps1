Function Set-HaloOpportunity {
    <#
        .SYNOPSIS
            Updates an opportunity via the Halo API.
        .DESCRIPTION
            Function to send an opportunity update request to the Halo API
        .OUTPUTS
            Outputs an object containing the response from the web request.
    #>
    [CmdletBinding( SupportsShouldProcess = $True )]
    [OutputType([Object])]
    Param (
        # Object containing properties and values used to update an existing opportunity.
        [Parameter( Mandatory = $True, ValueFromPipeline )]
        [Object]$Opportunity
    )
    Invoke-HaloPreFlightCheck
    $CommandName = $MyInvocation.InvocationName
    try {
        $ObjectToUpdate = Get-HaloOpportunity -OpportunityID $Opportunity.id
        if ($ObjectToUpdate) {
            if ($PSCmdlet.ShouldProcess("Opportunity '$($ObjectToUpdate.summary)'", 'Update')) {
                New-HaloPOSTRequest -Object $Opportunity -Endpoint 'opportunities' -Update
            }
        } else {
            Throw 'Opportunity was not found in Halo to update.'
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