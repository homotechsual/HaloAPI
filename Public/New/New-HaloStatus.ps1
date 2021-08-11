Function New-HaloStatus {
    <#
    .SYNOPSIS
        Creates a status via the Halo API.
    .DESCRIPTION
        Function to send a status creation request to the Halo API
    .OUTPUTS
        Outputs an object containing the response from the web request.
    #>
    [CmdletBinding()]
    Param (
        # Object containing properties and values used to create a new status.
        [Parameter( Mandatory = $True )]
        [PSCustomObject]$Status
    )
    Invoke-HaloUpdate -Object $Status -Endpoint "status"
}