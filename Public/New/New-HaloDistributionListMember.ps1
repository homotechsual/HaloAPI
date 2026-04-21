Function New-HaloDistributionListMember {
    <#
        .SYNOPSIS
            Adds one or more members to a distribution list via the Halo API.
        .DESCRIPTION
            Function to send a request to add members to a distribution list in the Halo API
        .OUTPUTS
            Outputs an object containing the response from the web request.
    #>
    [CmdletBinding( SupportsShouldProcess = $True )]
    [OutputType([Object[]])]
    Param (
        # Distribution List ID
        [Parameter( Mandatory = $True )]
        [int64]$DistributionListID,
        # Object or array of objects containing properties and values used to add one or more members to the distribution list.
        [Parameter( Mandatory = $True )]
        [Object[]]$Member
    )
    Invoke-HaloPreFlightCheck
    try {
        if ($PSCmdlet.ShouldProcess("Distribution List members", 'Add')) {
            $Resource = "api/distributionlist/$($DistributionListID)/members"
            $Results = New-HaloPOSTRequest -Object $Member -Resource $Resource
            Return $Results
        }
    } catch {
        New-HaloError -ErrorRecord $_
    }
}
