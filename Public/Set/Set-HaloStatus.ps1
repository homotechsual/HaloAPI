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
        # Object containing properties and values used to update an existing status.
        [Parameter( Mandatory = $True )]
        [PSCustomObject]$Status
    )
    Invoke-HaloUpdate -Object $Status -Endpoint "status" -Update
}