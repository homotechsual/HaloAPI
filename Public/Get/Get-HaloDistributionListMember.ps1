#Requires -Version 7
function Get-HaloDistributionListMember {
    <#
        .SYNOPSIS
            Gets members of a distribution list from the Halo API.
        .DESCRIPTION
            Retrieves members of a specific distribution list from the Halo API.
        .OUTPUTS
            A powershell object containing the response.
    #>
    [CmdletBinding()]
    [OutputType([Object])]
    Param(
        # Distribution List ID
        [Parameter( Mandatory = $True )]
        [int64]$DistributionListID,
        # Paginate results
        [Alias('pageinate')]
        [switch]$Paginate,
        # Number of results per page.
        [Alias('page_size')]
        [int32]$PageSize,
        # Which page to return.
        [Alias('page_no')]
        [int32]$PageNo
    )
    Invoke-HaloPreFlightCheck
    try {
        Write-Verbose "Getting members for distribution list ID: $DistributionListID"
        $QSCollection = @{}
        if ($Paginate) {
            if ($PageSize) {
                $QSCollection['page_size'] = $PageSize
            }
            if ($PageNo) {
                $QSCollection['page_no'] = $PageNo
            }
        }
        $Resource = "api/distributionlist/$($DistributionListID)/members"
        $RequestParams = @{
            Method = 'GET'
            Resource = $Resource
            AutoPaginateOff = $Paginate
            QSCollection = $QSCollection
            ResourceType = 'distributionlistmembers'
        }
        $MemberResults = New-HaloGETRequest @RequestParams
        Return $MemberResults
    } catch {
        New-HaloError -ErrorRecord $_
    }
}
