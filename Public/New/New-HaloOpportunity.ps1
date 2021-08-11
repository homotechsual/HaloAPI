Function New-HaloOpportunity {
    <#
        .SYNOPSIS
            Creates an opportunity via the Halo API.
        .DESCRIPTION
            Function to send an opportunity creation request to the Halo API
        .OUTPUTS
            Outputs an object containing the response from the web request.
    #>
    [CmdletBinding( SupportsShouldProcess = $True )]
    [OutputType([PSCustomObject])]
    Param (
        # Object containing properties and values used to create a new opportunity.
        [Parameter( Mandatory = $True )]
        [PSCustomObject]$Opportunity
    )
    if ($PSCmdlet.ShouldProcess("Opportunity", "Create")) {
        Invoke-HaloUpdate -Object $Opportunity -Endpoint "opportunities"
    }
}