Function Set-HaloBillingTemplate {
    <#
        .SYNOPSIS
            Updates a billing template via the Halo API.
        .DESCRIPTION
            Function to send an billing template update request to the Halo API
        .OUTPUTS
            Outputs an object containing the response from the web request.
    #>
    [CmdletBinding( SupportsShouldProcess = $True )]
    [OutputType([Object])]
    Param (
        # Object containing properties and values used to update an existing billing template.
        [Parameter( Mandatory = $True )]
        [Object]$Template
    )
    Invoke-HaloPreFlightChecks
    $CommandName = $MyInvocation.InvocationName
    try {
        $ObjectToUpdate = Get-HaloBillingTemplate -TemplateID $Template.id
        if ($ObjectToUpdate) {
            if ($PSCmdlet.ShouldProcess("Billing Template '$($ObjectToUpdate.name)'", 'Update')) {
                New-HaloPOSTRequest -Object $Template -Endpoint 'billingtemplate' -Update
            }
        } else {
            Throw 'Billing Template was not found in Halo to update.'
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