Function Set-HaloAttachment {
    <#
    .SYNOPSIS
        Updates an attachment via the Halo API.
    .DESCRIPTION
        Function to send an attachment update request to the Halo API
    .OUTPUTS
        Outputs an object containing the response from the web request.
    #>
    [CmdletBinding()]
    Param (
        [Parameter( Mandatory = $True )]
        [PSCustomObject]$Attachment
    )
    Invoke-HaloUpdate -Object $Attachment -Endpoint "attachment" -Update
}