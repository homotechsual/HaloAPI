Function Set-HaloSupplier {
    <#
        .SYNOPSIS
            Updates a supplier via the Halo API.
        .DESCRIPTION
            Function to send a supplier update request to the Halo API
        .OUTPUTS
            Outputs an object containing the response from the web request.
    #>
    [CmdletBinding( SupportsShouldProcess = $True )]
    [OutputType([Object])]
    Param (
        # Object containing properties and values used to update an existing supplier.
        [Parameter( Mandatory = $True )]
        [Object]$Supplier
    )
    Invoke-HaloPreFlightChecks
    $CommandName = $MyInvocation.InvocationName
    try {
        $ObjectToUpdate = Get-HaloSupplier -SupplierID $Supplier.id
        if ($ObjectToUpdate) {
            if ($PSCmdlet.ShouldProcess("Supplier '$($ObjectToUpdate.name)'", 'Update')) {
                New-HaloPOSTRequest -Object $Supplier -Endpoint 'supplier' -Update
            }
        } else {
            Throw 'Supplier was not found in Halo to update.'
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