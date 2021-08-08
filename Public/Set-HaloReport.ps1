Function Set-HaloReport {
    <#
    .SYNOPSIS
        Updates a report via the Halo API.
    .DESCRIPTION
        Function to send a report creation update to the Halo API
    .OUTPUTS
        Outputs an object containing the response from the web request.
    #>
    [CmdletBinding()]
    Param (
        [Parameter( Mandatory = $True )]
        [PSCustomObject]$Report
    )
    Invoke-HaloUpdate -Object $Report -Endpoint "report" -Update
}