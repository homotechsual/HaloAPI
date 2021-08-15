Function New-HaloCustomButton {
    <#
        .SYNOPSIS
            Creates a custom button via the Halo API.
        .DESCRIPTION
            Function to send a custom button creation request to the Halo API
        .OUTPUTS
            Outputs an object containing the response from the web request.
    #>
    [CmdletBinding( SupportsShouldProcess = $True )]
    [OutputType([Object])]
    Param (
        # Object containing properties and values used to create a new custom button.
        [Parameter( Mandatory = $True )]
        [Object]$CustomButton
    )
    try {
        if ($PSCmdlet.ShouldProcess("Custom Button '$($CustomButton.name)'", "Create")) {
            New-HaloPOSTRequest -Object $CustomButton -Endpoint "custombutton"
        }
    } catch {
        Write-Error "Failed to create custom button with the Halo API. You'll see more detail if using '-Verbose'"
        Write-Verbose "$_"
    }
}