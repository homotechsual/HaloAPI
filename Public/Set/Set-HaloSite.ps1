Function Set-HaloSite {
    <#
        .SYNOPSIS
            Updates a site via the Halo API.
        .DESCRIPTION
            Function to send a site update request to the Halo API
        .OUTPUTS
            Outputs an object containing the response from the web request.
    #>
    [CmdletBinding( SupportsShouldProcess = $True )]
    [OutputType([Object])]
    Param (
        # Object containing properties and values used to update an existing site.
        [Parameter( Mandatory = $True, ValueFromPipeline )]
        [Object]$Site
    )
    Invoke-HaloPreFlightCheck
    $CommandName = $MyInvocation.InvocationName
    try {
        $ObjectToUpdate = Get-HaloSite -SiteID $Site.id
        if ($ObjectToUpdate) {
            if ($PSCmdlet.ShouldProcess("Site '$($ObjectToUpdate.name)'", 'Update')) {
                New-HaloPOSTRequest -Object $Site -Endpoint 'site' -Update
            }
        } else {
            Throw 'Site was not found in Halo to update.'
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