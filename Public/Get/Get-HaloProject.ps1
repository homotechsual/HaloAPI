#Requires -Version 7
function Get-HaloProject {
    <#
        .SYNOPSIS
            Gets projects from the Halo API.
        .DESCRIPTION
            Retrieves projects from the Halo API - supports a variety of filtering parameters.
        .OUTPUTS
            A powershell object containing the response.
    #>
    [CmdletBinding( DefaultParameterSetName = 'Multi' )]
    [OutputType([Object])]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', '', Justification = 'Uses dynamic parameter parsing.')]
    Param(
        # Project ID
        [Parameter( ParameterSetName = 'Single', Mandatory = $True )]
        [int64]$ProjectID,
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
        # Return only the 'ID' fields (Ticket ID, SLA ID, Status ID, Client ID, Client Name and Last Incoming Email date)
        [Parameter( ParameterSetName = 'Single' )]
        [Parameter( ParameterSetName = 'Multi' )]
        [switch]$TicketIDOnly,
        # The ID of the filter profile to use to filter results.
        [Parameter( ParameterSetName = 'Multi' )]
        [Alias('view_id')]
        [int32]$ViewID,
        # The ID of the column profile to use to control data returned in the results.
        [Parameter( ParameterSetName = 'Multi' )]
        [Alias('columns_id')]
        [int32]$ColumnsID,
        # Include column details in the the results.
        [Parameter( ParameterSetName = 'Multi' )]
        [switch]$IncludeColumns,
        # Include SLA action date in the results.
        [Parameter( ParameterSetName = 'Multi' )]
        [switch]$IncludeSLAActionDate,
        # Include SLA timer in the results.
        [Parameter( ParameterSetName = 'Multi' )]
        [switch]$IncludeSLATimer,
        # Include time taken in the results.
        [Parameter( ParameterSetName = 'Multi' )]
        [switch]$IncludeTimeTaken,
        # Include supplier details in the results.
        [Parameter( ParameterSetName = 'Multi' )]
        [switch]$IncludeSupplier,
        # Include release 1 details in the results.
        [Parameter( ParameterSetName = 'Multi' )]
        [switch]$IncludeRelease1,
        # Include release 2 details in the results.
        [Parameter( ParameterSetName = 'Multi' )]
        [switch]$IncludeRelease2,
        # Include release 3 details in the results.
        [Parameter( ParameterSetName = 'Multi' )]
        [switch]$IncludeRelease3,
        # Include child ticket IDs in the results.
        [Parameter( ParameterSetName = 'Multi' )]
        [switch]$IncludeChildIDs,
        # Include next activity date in the results.
        [Parameter( ParameterSetName = 'Multi' )]
        [switch]$IncludeNextActivityDate,
        # Filter by the specified list.
        [Parameter( ParameterSetName = 'Multi' )]
        [Alias('list_id')]
        [int32]$ListID,
        # Filter by the specified agent.
        [Parameter( ParameterSetName = 'Multi' )]
        [Alias('agent_id')]
        [int32]$AgentID,
        # Filter by the specified status.
        [Parameter( ParameterSetName = 'Multi' )]
        [Alias('status_id')]
        [int32]$StatusID,
        # Filter by the specified request type.
        [Parameter( ParameterSetName = 'Multi' )]
        [Alias('requesttype_id')]
        [int32]$RequestTypeID,
        # Filter by the specified supplier.
        [Parameter( ParameterSetName = 'Multi' )]
        [Alias('supplier_id')]
        [int32]$SupplierID,
        # Filter by the specified client.
        [Parameter( ParameterSetName = 'Multi' )]
        [Alias('client_id')]
        [int32]$ClientID,
        # Filter by the specified site.
        [Parameter( ParameterSetName = 'Multi' )]
        [int32]$Site,
        # Filter by the specified user name.
        [Parameter( ParameterSetName = 'Multi' )]
        [string]$UserName,
        # Filter by the specified user ID.
        [Parameter( ParameterSetName = 'Multi' )]
        [Alias('user_id')]
        [int32]$UserID,
        # Filter by the specified release.
        [Parameter( ParameterSetName = 'Multi' )]
        [Alias('release_id')]
        [int32]$ReleaseID,
        # Filter by the specified asset.
        [Parameter( ParameterSetName = 'Multi' )]
        [Alias('asset_id')]
        [int32]$AssetID,
        # Filter by the specified ITIL request type.
        [Parameter( ParameterSetName = 'Multi' )]
        [Alias('itil_requesttype_id')]
        [int32]$ITILRequestTypeID,
        # Return only open tickets in the results.
        [Parameter( ParameterSetName = 'Multi' )]
        [Alias('open_only')]
        [switch]$OpenOnly,
        # Return only closed tickets in the results.
        [Parameter( ParameterSetName = 'Multi' )]
        [Alias('closed_only')]
        [switch]$ClosedOnly,
        # Return only unlinked tickets in the results.
        [Parameter( ParameterSetName = 'Multi' )]
        [Alias('unlinked_only')]
        [switch]$UnlinkedOnly,
        # Filter by the specified contract ID.
        [Parameter( ParameterSetName = 'Multi' )]
        [Alias('contract_id')]
        [int32]$ContractID,
        # Return only tickets with attachments in the results.
        [Parameter( ParameterSetName = 'Multi' )]
        [switch]$WithAttachments,
        # Filter by the specified array of team IDs.
        [Parameter( ParameterSetName = 'Multi' )]
        [int32[]]$Team,
        # Filter by the specified array of agent IDs.
        [Parameter( ParameterSetName = 'Multi' )]
        [int32[]]$Agent,
        # Filter by the specified array of status IDs.
        [Parameter( ParameterSetName = 'Multi' )]
        [int32[]]$Status,
        # Filter by the specified array of request type IDs.
        [Parameter( ParameterSetName = 'Multi' )]
        [int32[]]$RequestType,
        # Filter by the specified array of ITIL request type IDs.
        [Parameter( ParameterSetName = 'Multi' )]
        [Alias('itil_requesttype')]
        [int32[]]$ITILRequestType,
        # Filter by the specified array of category 1 IDs.
        [Parameter( ParameterSetName = 'Multi' )]
        [Alias('category_1')]
        [int32[]]$Category1,
        # Filter by the specified array of category 2 IDs.
        [Parameter( ParameterSetName = 'Multi' )]
        [Alias('category_2')]
        [int32[]]$Category2,
        # Filter by the specified array of category 3 IDs.
        [Parameter( ParameterSetName = 'Multi' )]
        [Alias('category_3')]
        [int32[]]$Category3,
        # Filter by the specified array of category 4 IDs.
        [Parameter( ParameterSetName = 'Multi' )]
        [Alias('category_4')]
        [int32[]]$Category4,
        # Filter by the specified array of SLA IDs.
        [Parameter( ParameterSetName = 'Multi' )]
        [int32[]]$SLA,
        # Filter by the specified array of priority IDs.
        [Parameter( ParameterSetName = 'Multi' )]
        [int32[]]$Priority,
        # Filter by the specified array of product IDs.
        [Parameter( ParameterSetName = 'Multi' )]
        [int32[]]$Products,
        # Filter by the specified array of flagged ticket IDs.
        [Parameter( ParameterSetName = 'Multi' )]
        [int32[]]$Flagged,
        # Exclude the specified array of ticket IDs.
        [Parameter( ParameterSetName = 'Multi' )]
        [int32[]]$ExcludeThese,
        # Return tickets matching the search term in the results.
        [Parameter( ParameterSetName = 'Multi' )]
        [string]$Search,
        # Include actions when searching.
        [Parameter( ParameterSetName = 'Multi' )]
        [switch]$SearchActions,
        # Which date field to search against.
        [Parameter( ParameterSetName = 'Multi' )]
        [string]$DateSearch,
        # Start date for use with the '-datesearch' parameter.
        [Parameter( ParameterSetName = 'Multi' )]
        [string]$StartDate,
        # End date for use with the '-datesearch' parameter.
        [Parameter( ParameterSetName = 'Multi' )]
        [string]$EndDate,
        # Return tickets where the user name matches the search term.
        [Parameter( ParameterSetName = 'Multi' )]
        [Alias('search_user_name')]
        [string]$SearchUserName,
        # Return tickets where the summary matches the search term.
        [Parameter( ParameterSetName = 'Multi' )]
        [Alias('search_summary')]
        [string]$SearchSummary,
        # Return tickets where the details matches the search term.
        [Parameter( ParameterSetName = 'Multi' )]
        [Alias('search_details')]
        [string]$SearchDetails,
        # Return tickets where the reported by matches the search term.
        [Parameter( ParameterSetName = 'Multi' )]
        [Alias('search_reportedby')]
        [string]$SearchReportedBy,
        # Return tickets where the software version matches the search term.
        [Parameter( ParameterSetName = 'Multi' )]
        [Alias('search_version')]
        [string]$SearchVersion,
        # Return tickets where release 1 matches the search term.
        [Parameter( ParameterSetName = 'Multi' )]
        [Alias('search_release1')]
        [string]$SearchRelease1,
        # Return tickets where release 2 matches the search term.
        [Parameter( ParameterSetName = 'Multi' )]
        [Alias('search_release2')]
        [string]$SearchRelease2,
        # Return tickets where release 3 matches the search term.
        [Parameter( ParameterSetName = 'Multi' )]
        [Alias('search_release3')]
        [string]$SearchRelease3,
        # Return tickets where the release note matches the search term.
        [Parameter( ParameterSetName = 'Multi' )]
        [Alias('search_releasenote')]
        [string]$SearchReleaseNote,
        # Return tickets where the asset tag matches the search term.
        [Parameter( ParameterSetName = 'Multi' )]
        [Alias('search_invenotry_number')]
        [string]$SearchInventoryNumber,
        # Return tickets where the opportunity contact name matches the search term.
        [Parameter( ParameterSetName = 'Multi' )]
        [Alias('search_oppcontactname')]
        [string]$SearchOppContactName,
        # Return tickets where the opportunity company name matches the search term.
        [Parameter( ParameterSetName = 'Multi' )]
        [Alias('search_oppcompanyname')]
        [string]$SearchOppCompanyName,
        # Include upcoming appointment ID in the response
        [Parameter( ParameterSetName = 'Multi' )]
        [string]$IncludeAppointmentID,
        # Include extra objects in the result.
        [Parameter( ParameterSetName = 'Single' )]
        [Switch]$IncludeDetails,
        # Include the last action in the result.
        [Parameter( ParameterSetName = 'Single' )]
        [Switch]$IncludeLastAction
    )
    Invoke-HaloPreFlightCheck
    $CommandName = $MyInvocation.MyCommand.Name
    $Parameters = (Get-Command -Name $CommandName).Parameters
    # Workaround to prevent the query string processor from adding a 'ProjectID=' parameter by removing it from the set parameters.
    if ($ProjectID) {
        $Parameters.Remove('ProjectID') | Out-Null
    }
    try {
        if ($ProjectID) {
            Write-Verbose "Running in single-project mode because '-ProjectID' was provided."
            $QSCollection = New-HaloQuery -CommandName $CommandName -Parameters $Parameters
            $Resource = "api/projects/$($ProjectID)"
            $RequestParams = @{
                Method = 'GET'
                Resource = $Resource
                AutoPaginateOff = $True
                QSCollection = $QSCollection
                ResourceType = 'tickets'
            }
        } else {
            Write-Verbose 'Running in multi-project mode.'
            $QSCollection = New-HaloQuery -CommandName $CommandName -Parameters $Parameters -IsMulti
            $Resource = 'api/projects'
            $RequestParams = @{
                Method = 'GET'
                Resource = $Resource
                AutoPaginateOff = $Paginate
                QSCollection = $QSCollection
                ResourceType = 'tickets'
            }
        }
        $ProjectResults = New-HaloGETRequest @RequestParams
        Return $ProjectResults
    } catch {
        New-HaloError -ErrorRecord $_
    }
}