Function Set-HaloAttachment {
    <#
        .SYNOPSIS
            Updates an attachment via the Halo API.
        .DESCRIPTION
            Function to send an attachment update request to the Halo API
        .OUTPUTS
            Outputs an object containing the response from the web request.
    #>
    [CmdletBinding( SupportsShouldProcess = $True )]
    [OutputType([PSCustomObject])]
    Param (
        # Object containing properties and values used to update an existing attachment.
        [Parameter( Mandatory = $True )]
        [PSCustomObject]$Attachment
    )
    if ($PSCmdlet.ShouldProcess("Attachment", "Update")) {
        Invoke-HaloUpdate -Object $Attachment -Endpoint "attachment" -Update
    }
}