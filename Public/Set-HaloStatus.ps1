Function Set-HaloStatus {
    <#
    .SYNOPSIS
        Updates a status via the Halo API.
    .DESCRIPTION
        Function to send a status update request to the Halo API
    .OUTPUTS
        Outputs an object containing the response from the web request.
    #>
    [CmdletBinding()]
    Param (
        [Parameter( Mandatory = $True )]
        [PSCustomObject]$Status
    )
    Invoke-HaloUpdate -Object $Status -Endpoint "status" -Update
}