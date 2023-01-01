Function Set-HaloCustomButton {
    <#
        .SYNOPSIS
            Updates a custom button via the Halo API.
        .DESCRIPTION
            Function to send a custom button update request to the Halo API
        .OUTPUTS
            Outputs an object containing the response from the web request.
    #>
    [CmdletBinding( SupportsShouldProcess = $True )]
    [OutputType([Object])]
    Param (
        # Object containing properties and values used to update an existing contract.
        [Parameter( Mandatory = $True, ValueFromPipeline )]
        [Object]$CustomButton,
        # Skip validation checks.
        [Parameter()]
        [Switch]$SkipValidation
    )
    Invoke-HaloPreFlightCheck
    try {
        if ($null -eq $CustomButton.id) {
            throw 'Custom button ID is required.'
        }
        if (-not $SkipValidation) {
            $ObjectToUpdate = Get-HaloCustomButton -CustomButtonID $CustomButton.id
        } else {
            Write-Verbose 'Skipping validation checks.'
            $ObjectToUpdate = $True
        }
        if ($ObjectToUpdate) {
            if ($PSCmdlet.ShouldProcess('Custom Button', 'Update')) {
                New-HaloPOSTRequest -Object $CustomButton -Endpoint 'custombutton'
            }
        } else {
            Throw 'Custom button was not found in Halo to update.'
        }
    } catch {
        New-HaloError -ErrorRecord $_
    }
}