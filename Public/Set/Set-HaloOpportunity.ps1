Function Set-HaloOpportunity {
    <#
        .SYNOPSIS
            Updates one or more opportunities via the Halo API.
        .DESCRIPTION
            Function to send an opportunity update request to the Halo API
        .OUTPUTS
            Outputs an object containing the response from the web request.
    #>
    [CmdletBinding( SupportsShouldProcess = $True )]
    [OutputType([Object[]])]
    Param (
        # Object or array of objects containing properties and values used to update one or more existing opportunities.
        [Parameter( Mandatory = $True, ValueFromPipeline )]
        [Object[]]$Opportunity
    )
    Invoke-HaloPreFlightCheck
    try {
        $ObjectToUpdate = $False
        ForEach-Object -InputObject $Opportunity {
            $HaloOpportunityParams = @{
                OpportunityId = $_.id
            }
            $OpportunityExists = Get-HaloOpportunity @HaloOpportunityParams
            if ($OpportunityExists) {
                Set-Variable -Scope 1 -Name 'ObjectToUpdate' -Value $True
            }
        }
        if ($ObjectToUpdate) {
            if ($PSCmdlet.ShouldProcess($Opportunity -is [Array] ? 'Opportunities' : 'Opportunity', 'Update')) {
                New-HaloPOSTRequest -Object $Opportunity -Endpoint 'opportunities' -Update
            }
        } else {
            Throw 'One or more opportunities was not found in Halo to update.'
        }
    } catch {
        New-HaloError -ErrorRecord $_
    }
}