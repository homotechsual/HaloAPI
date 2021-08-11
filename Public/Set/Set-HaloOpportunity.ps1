Function Set-HaloOpportunity {
    <#
    .SYNOPSIS
        Updates an opportunity via the Halo API.
    .DESCRIPTION
        Function to send an opportunity update request to the Halo API
    .OUTPUTS
        Outputs an object containing the response from the web request.
    #>
    [CmdletBinding()]
    Param (
        # Object containing properties and values used to update an existing opportunity.
        [Parameter( Mandatory = $True )]
        [PSCustomObject]$Opportunity
    )
    Invoke-HaloUpdate -Object $Opportunity -Endpoint "opportunities" -Update
}