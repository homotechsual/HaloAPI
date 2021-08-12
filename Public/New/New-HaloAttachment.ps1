Function New-HaloAttachment {
    <#
        .SYNOPSIS
            Creates an attachment via the Halo API.
        .DESCRIPTION
            Function to send an attachment creation request to the Halo API
        .OUTPUTS
            Outputs an object containing the response from the web request.
    #>
    [CmdletBinding( SupportsShouldProcess = $True )]
    [OutputType([Object])]
    Param (
        # Object containing properties and values used to create a new attachment.
        [Parameter( Mandatory = $True )]
        [Object]$Attachment
    )
    try {
        if ($PSCmdlet.ShouldProcess("Attachment '$($Attachment.filename)'", "Create")) {
            New-HaloPOSTRequest -Object $Attachment -Endpoint "attachment"
        }
    } catch {
        Write-Error "Failed to create attachment with the Halo API. You'll see more detail if using '-Verbose'"
        Write-Verbose "$_"
    }
}