Function Set-HaloRecurringTemplate {
    <#
        .SYNOPSIS
            Updates a recurring invoice schedule template via the Halo API.
        .DESCRIPTION
            Function to send a recurring invoice schedule template update request to the Halo API
        .OUTPUTS
            Outputs an object containing the response from the web request.
    #>
    [CmdletBinding( SupportsShouldProcess = $True )]
    [OutputType([Object])]
    Param (
        # Object containing properties and values used to update an existing invoice.
        [Parameter( Mandatory = $True, ValueFromPipeline )]
        [Object]$Template
    )
    Invoke-HaloPreFlightCheck
    $CommandName = $MyInvocation.InvocationName
    try {        
        if ($PSCmdlet.ShouldProcess("Template '$($ObjectToUpdate.id)'", 'Update')) {
            New-HaloPOSTRequest -Object $Template -Endpoint 'template' -Update
        }
    } catch {
        $Command = $CommandName -Replace '-', ''
        $ErrorRecord = @{
            ExceptionType   = 'System.Exception'
            ErrorMessage    = "$($CommandName) failed."
            InnerException  = $_.Exception
            ErrorID         = "Halo$($Command)CommandFailed"
            ErrorCategory   = 'ReadError'
            TargetObject    = $_.TargetObject
            ErrorDetails    = $_.ErrorDetails
            BubbleUpDetails = $False
        }
        $CommandError = New-HaloErrorRecord @ErrorRecord
        $PSCmdlet.ThrowTerminatingError($CommandError)
    }
}