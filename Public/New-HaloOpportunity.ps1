Function New-HaloOpportunity {
    <#
    .SYNOPSIS
        Creates an Opportunity via the Halo API.
    .DESCRIPTION
        Function to send an Opportunity creation request to the Halo API
    .OUTPUTS
        Outputs an object containing the response from the web request.
    #>
    [CmdletBinding()]
    Param (
        [Parameter( Mandatory = $True )]
        [PSCustomObject]$Opportunity
    )
    Invoke-HaloUpdate -Object $Opportunity -Endpoint "Opportunities"
}