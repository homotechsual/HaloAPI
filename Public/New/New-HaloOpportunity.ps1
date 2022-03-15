Function New-HaloOpportunity {
    <#
        .SYNOPSIS
            Creates one or more opportunities via the Halo API.
        .DESCRIPTION
            Function to send an opportunity creation request to the Halo API
        .OUTPUTS
            Outputs an object containing the response from the web request.
    #>
    [CmdletBinding( SupportsShouldProcess = $True )]
    [OutputType([Object[]])]
    Param (
        # Object or array of objects containing properties and values used to create one or more new opportunities.
        [Parameter( Mandatory = $True )]
        [Object[]]$Opportunity
    )
    Invoke-HaloPreFlightCheck
    try {
        if ($PSCmdlet.ShouldProcess($Opportunity -is [Array] ? 'Opportunities' : 'Opportunity', 'Create')) {
            New-HaloPOSTRequest -Object $Opportunity -Endpoint 'opportunities'
        }
    } catch {
        New-HaloError -ErrorRecord $_
    }
}