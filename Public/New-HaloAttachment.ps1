Function New-HaloAttachment {
    <#
    .SYNOPSIS
        Creates an Attachment via the Halo API.
    .DESCRIPTION
        Function to send an Attachment creation request to the Halo API
    .OUTPUTS
        Outputs an object containing the response from the web request.
    #>
    [CmdletBinding()]
    Param (
        [Parameter( Mandatory = $True )]
        [PSCustomObject]$Attachment
    )
    Invoke-HaloUpdate -Object $Attachment -Endpoint "Attachment"
}