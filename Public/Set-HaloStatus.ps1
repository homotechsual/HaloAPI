Function Set-HaloStatus {
    <#
    .SYNOPSIS
        Updates a Status via the Halo API.
    .DESCRIPTION
        Function to send a Status update request to the Halo API
    .OUTPUTS
        Outputs an object containing the response from the web request.
    #>
    [CmdletBinding()]
    Param (
        [Parameter( Mandatory = $True )]
        [PSCustomObject]$Status
    )
    Invoke-HaloUpdate -Object $Status -Endpoint "Status" -update
}