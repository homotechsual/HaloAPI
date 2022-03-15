Function New-HaloAttachment {
    <#
        .SYNOPSIS
            Creates one or more attachments via the Halo API.
        .DESCRIPTION
            Function to send an attachment creation request to the Halo API
        .OUTPUTS
            Outputs an object containing the response from the web request.
    #>
    [CmdletBinding( SupportsShouldProcess = $True )]
    [OutputType([Object[]])]
    Param (
        # Object or array of objects containing properties and values used to create one or more new attachments.
        [Parameter( Mandatory = $True )]
        [Object[]]$Attachment
    )
    Invoke-HaloPreFlightCheck
    try {
        if ($PSCmdlet.ShouldProcess($Attachment -is [Array] ? 'Attachments' : 'Attachment', 'Create')) {
            New-HaloPOSTRequest -Object $Attachment -Endpoint 'attachment'
        }
    } catch {
        New-HaloError -ErrorRecord $_
    }
}