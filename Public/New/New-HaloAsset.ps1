Function New-HaloAsset {
    <#
        .SYNOPSIS
            Creates an asset via the Halo API.
        .DESCRIPTION
            Function to send an asset creation request to the Halo API
        .OUTPUTS
            Outputs an object containing the response from the web request.
    #>
    [CmdletBinding( SupportsShouldProcess = $True )]
    [OutputType([Object])]
    Param (
        # Object containing properties and values used to create a new asset.
        [Parameter( Mandatory = $True )]
        [Object]$Asset
    )
    Invoke-HaloPreFlightCheck
    $CommandName = $MyInvocation.InvocationName
    try {
        if ($PSCmdlet.ShouldProcess("Asset $($Asset.inventory_number)", 'Create')) {
            New-HaloPOSTRequest -Object $Asset -Endpoint 'asset'
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