function Remove-HaloDistributionListMember {
    <#
        .SYNOPSIS
           Removes a member from a distribution list in the Halo API.
        .DESCRIPTION
            Deletes a specific member from a distribution list in Halo.
        .OUTPUTS
            A powershell object containing the response.
    #>
    [cmdletbinding( SupportsShouldProcess = $True, ConfirmImpact = 'High' )]
    [OutputType([Object])]
    Param(
        # Distribution List ID
        [Parameter( Mandatory = $True )]
        [int64]$DistributionListID,
        # The member ID or email to remove
        [Parameter( Mandatory = $True )]
        [string]$Member
    )
    Invoke-HaloPreFlightCheck
    try {
        if ($PSCmdlet.ShouldProcess(('Member ''{0}'' from Distribution List' -f $Member), 'Remove')) {
            $Resource = ('api/distributionlist/{0}/members/{1}' -f $DistributionListID, [uri]::EscapeDataString($Member))
            $MemberResults = New-HaloDELETERequest -Resource $Resource
            Return $MemberResults
        }
    } catch {
        New-HaloError -ErrorRecord $_
    }
}
