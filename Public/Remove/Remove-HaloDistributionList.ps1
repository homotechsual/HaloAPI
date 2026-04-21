function Remove-HaloDistributionList {
    <#
        .SYNOPSIS
           Removes a distribution list from the Halo API.
        .DESCRIPTION
            Deletes a specific distribution list from Halo.
        .OUTPUTS
            A powershell object containing the response.
    #>
    [cmdletbinding( SupportsShouldProcess = $True, ConfirmImpact = 'High' )]
    [OutputType([Object])]
    Param(
        # The Distribution List ID
        [Parameter( Mandatory = $True )]
        [Alias('DistributionList')]
        [int64]$DistributionListID
    )
    Invoke-HaloPreFlightCheck
    try {
        $ObjectToDelete = Get-HaloDistributionList -DistributionListID $DistributionListID
        if ($ObjectToDelete) {
            if ($PSCmdlet.ShouldProcess("Distribution List '$($ObjectToDelete.name)'", 'Delete')) {
                $Resource = "api/distributionlist/$($DistributionListID)"
                $DistributionListResults = New-HaloDELETERequest -Resource $Resource
                Return $DistributionListResults
            }
        } else {
            Throw 'Distribution List was not found in Halo to delete.'
        }
    } catch {
        New-HaloError -ErrorRecord $_
    }
}
