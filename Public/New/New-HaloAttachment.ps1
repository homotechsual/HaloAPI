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
    [OutputType([PSCustomObject])]
    Param (
        # Object containing properties and values used to create a new attachment.
        [Parameter( Mandatory = $True )]
        [PSCustomObject]$Attachment
    )
    if ($PSCmdlet.ShouldProcess("Attachment", "Create")) {
        Invoke-HaloUpdate -Object $Attachment -Endpoint "attachment"
    }
}