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
    [OutputType([Object])]
    Param (
        # Object containing properties and values used to create a new opportunity.
        [Parameter( Mandatory = $True )]
        [Object]$Opportunity
    )
    try {
        if ($PSCmdlet.ShouldProcess("Opportunity '$($Opportunity.summary)'", "Create")) {
            New-HaloPOSTRequest -Object $Opportunity -Endpoint "opportunities"
        }
    } catch {
        Write-Error "Failed to create opportunity with the Halo API. You'll see more detail if using '-Verbose'"
        Write-Verbose "$_"
    }
}