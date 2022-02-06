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
    Invoke-HaloPreFlightCheck
    try {
        if ($PSCmdlet.ShouldProcess("Attachment '$($Attachment.filename)'", 'Create')) {
            New-HaloPOSTRequest -Object $Attachment -Endpoint 'attachment'
        }
    } catch {
        New-HaloError -ErrorRecord $_
    }
}