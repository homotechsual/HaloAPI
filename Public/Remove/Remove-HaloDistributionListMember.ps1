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
        if ($PSCmdlet.ShouldProcess("Member '$Member' from Distribution List", 'Remove')) {
            $Resource = "api/distributionlist/$($DistributionListID)/members/$Member"
            $MemberResults = New-HaloDELETERequest -Resource $Resource
            Return $MemberResults
        }
    } catch {
        New-HaloError -ErrorRecord $_
    }
}
