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
        [Parameter( Mandatory = $True )]
        [Object]$CustomButton
    )
    try {
        $ObjectToUpdate = Get-HaloCustomButton -CustomButtonID $CustomButton.id
        if ($ObjectToUpdate) {
            if ($PSCmdlet.ShouldProcess("Custom Button '$($ObjectToUpdate.name)'", "Update")) {
                New-HaloPOSTRequest -Object $CustomButton -Endpoint "custombutton" -Update
            }
        } else {
            Throw "Custom button was not found in Halo to update."
        }
    } catch {
        Write-Error "Failed to update custom button with the Halo API. You'll see more detail if using '-Verbose'"
        Write-Verbose "$_"
    }
}