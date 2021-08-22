Function Set-HaloItem {
    <#
        .SYNOPSIS
            Updates an item via the Halo API.
        .DESCRIPTION
            Function to send an item update request to the Halo API
        .OUTPUTS
            Outputs an object containing the response from the web request.
    #>
    [CmdletBinding( SupportsShouldProcess = $True )]
    [OutputType([Object])]
    Param (
        # Object containing properties and values used to update an existing item.
        [Parameter( Mandatory = $True )]
        [Object]$Item
    )
    Invoke-HaloPreFlightChecks
    $CommandName = $MyInvocation.InvocationName
    try {
        $ObjectToUpdate = Get-HaloItem -ItemID $Item.id
        if ($ObjectToUpdate) {
            if ($PSCmdlet.ShouldProcess("Item '$($ObjectToUpdate.name)'", 'Update')) {
                New-HaloPOSTRequest -Object $Item -Endpoint 'item' -Update
            }
        } else {
            Throw 'Item was not found in Halo to update.'
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