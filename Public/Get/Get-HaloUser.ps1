#Requires -Version 7
function Get-HaloUser {
    <#
        .SYNOPSIS
            Gets users from the Halo API.
        .DESCRIPTION
            Retrieves users from the Halo API - supports a variety of filtering parameters.
        .OUTPUTS
            A powershell object containing the response.
    #>
    [CmdletBinding( DefaultParameterSetName = 'Multi' )]
    [OutputType([Object])]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', '', Justification = 'Uses dynamic parameter parsing.')]
    Param(
        # User ID
        [Parameter( ParameterSetName = 'Single', Mandatory = $True )]
        [int64]$UserID,
        # Paginate results
        [Parameter( ParameterSetName = 'Multi' )]
        [Alias('pageinate')]
        [switch]$Paginate,
        # Number of results per page.
        [Parameter( ParameterSetName = 'Multi' )]
        [Alias('page_size')]
        [int32]$PageSize,
        # Which page to return.
        [Parameter( ParameterSetName = 'Multi' )]
        [Alias('page_no')]
        [int32]$PageNo,
        # Which field to order results based on.
        [Parameter( ParameterSetName = 'Multi' )]
        [string]$Order,
        # Order results in descending order (respects the field choice in '-Order')
        [Parameter( ParameterSetName = 'Multi' )]
        [switch]$OrderDesc,
        # Return users matching the search term in the results.
        [Parameter( ParameterSetName = 'Multi' )]
        [string]$Search,
        # Search on phone numbers when searching.
        [Parameter( ParameterSetName = 'Multi' )]
        [Alias('search_phonenumbers')]
        [switch]$SearchPhoneNumbers,
        # Filter by the specified top level ID.
        [Parameter( ParameterSetName = 'Multi' )]
        [Alias('toplevel_id')]
        [int32]$TopLevelID,
        # Filter by the specified client ID.
        [Parameter( ParameterSetName = 'Multi' )]
        [Alias('client_id')]
        [int32]$ClientID,
        # Filter by the specified site ID.
        [Parameter( ParameterSetName = 'Multi' )]
        [Alias('site_id')]
        [int32]$SiteID,
        # Filter by the specified organisation ID.
        [Parameter( ParameterSetName = 'Multi' )]
        [Alias('organisation_id')]
        [int32]$OrganisationID,
        # Filter by the specified department ID.
        [Parameter( ParameterSetName = 'Multi' )]
        [Alias('department_id')]
        [int32]$DepartmentID,
        # Filter by the specified asset ID.
        [Parameter( ParameterSetName = 'Multi' )]
        [Alias('asset_id')]
        [int32]$AssetID,
        # Include active users in the results.
        [Parameter( ParameterSetName = 'Multi' )]
        [switch]$IncludeActive,
        # Include inactive users in the results.
        [Parameter( ParameterSetName = 'Multi' )]
        [switch]$IncludeInactive,
        # Include approvers only in the results.
        [Parameter( ParameterSetName = 'Multi' )]
        [switch]$ApproversOnly,
        # Exclude users linked to agent accounts from the results.
        [Parameter( ParameterSetName = 'Multi' )]
        [switch]$ExcludeAgents,
        # The number of users to return if not using pagination.
        [Parameter( ParameterSetName = 'Multi' )]
        [int32]$Count,
        # Parameter to return the full objects.
        [Parameter( ParameterSetName = 'Multi' )]
        [switch]$FullObjects,
        # Include extra objects in the result.
        [Parameter( ParameterSetName = 'Single' )]
        [Switch]$IncludeDetails,
        # Include ticket activity in the result.
        [Parameter( ParameterSetName = 'Single' )]
        [Switch]$IncludeActivity,
        # Include customer popups in the result.
        [Parameter( ParameterSetName = 'Single' )]
        [Switch]$IncludePopups
    )
    Invoke-HaloPreFlightCheck
    $CommandName = $MyInvocation.MyCommand.Name
    $Parameters = (Get-Command -Name $CommandName).Parameters
    # Workaround to prevent the query string processor from adding a 'userid=' parameter by removing it from the set parameters.
    if ($UserID) {
        $Parameters.Remove('UserID') | Out-Null
    }
    # Similarly we don't want a `fullobjects=` parameter
    if ($FullObjects) {
        $Parameters.Remove('FullObjects') | Out-Null
    }
    try {
        if ($UserID) {
            Write-Verbose "Running in single-user mode because '-UserID' was provided."
            $QSCollection = New-HaloQuery -CommandName $CommandName -Parameters $Parameters
            $Resource = "api/users/$($UserID)"
            $RequestParams = @{
                Method = 'GET'
                Resource = $Resource
                AutoPaginateOff = $True
                QSCollection = $QSCollection
                ResourceType = 'users'
            }
        } else {
            Write-Verbose 'Running in multi-user mode.'
            $QSCollection = New-HaloQuery -CommandName $CommandName -Parameters $Parameters -IsMulti
            $Resource = 'api/users'
            $RequestParams = @{
                Method = 'GET'
                Resource = $Resource
                AutoPaginateOff = $Paginate
                QSCollection = $QSCollection
                ResourceType = 'users'
            }
        }
        $UserResults = New-HaloGETRequest @RequestParams
        if ($FullObjects) {
            $AllUserResults = $UserResults | ForEach-Object {             
                Get-HaloUser -UserID $_.id
            }
            $UserResults = $AllUserResults
        }
        Return $UserResults
    } catch {
        New-HaloError -ErrorRecord $_
    }
}