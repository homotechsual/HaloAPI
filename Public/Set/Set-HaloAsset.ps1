Function Set-HaloAsset {
    <#
        .SYNOPSIS
            Updates an asset via the Halo API.
        .DESCRIPTION
            Function to send an asset update request to the Halo API
        .OUTPUTS
            Outputs an object containing the response from the web request.
    #>
    [CmdletBinding( SupportsShouldProcess = $True )]
    [OutputType([Object])]
    Param (
        # Object containing properties and values used to update an existing asset.
        [Parameter( Mandatory = $True )]
        [Object]$Asset
    )
    Invoke-HaloPreFlightChecks
    $CommandName = $MyInvocation.InvocationName
    try {
        $ObjectToUpdate = Get-HaloAsset -AssetID $Asset.id
        if ($ObjectToUpdate) {
            if ($PSCmdlet.ShouldProcess("Asset '$($ObjectToUpdate.inventory_name)'", 'Update')) {
                New-HaloPOSTRequest -Object $Asset -Endpoint 'asset' -Update
            }
        } else {
            Throw 'Asset was not found in Halo to update.'
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