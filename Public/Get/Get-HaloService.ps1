#Requires -Version 7
function Get-HaloService {
    <#
        .SYNOPSIS
            Gets services from the Halo API.
        .DESCRIPTION
            Retrieves services from the Halo API - supports a variety of filtering parameters.
        .OUTPUTS
            A powershell object containing the response.
    #>
    [CmdletBinding( DefaultParameterSetName = 'Multi' )]
    [OutputType([Object])]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', '', Justification = 'Uses dynamic parameter parsing.')]
    Param(
        # Service ID
        [Parameter( ParameterSetName = 'Single', Mandatory = $True )]
        [int64]$ServiceID,
        # Number of records to return
        [Parameter( ParameterSetName = 'Multi' )]
        [int64]$Count,
        # Filters response based on the search string
        [Parameter( ParameterSetName = 'Multi' )]
        [string]$Search,
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
        # Filters by services accessible to the specified user.
        [Parameter( ParameterSetName = 'Multi' )]
        [Alias('user_id')]
        [int32]$UserID,
        # Filters by the specified array of operational status IDs.
        [Parameter( ParameterSetName = 'Multi' )]
        [Alias('service_status_ids')]
        [int32[]]$ServiceStatusIDs,
        # Filters by the specified service catalogue.
        [Parameter( ParameterSetName = 'Multi' )]
        [Alias('service_catalogue_type')]
        [int32]$ServiceCatalogueType,
        # Filters by the specified array of service category IDs.
        [Parameter( ParameterSetName = 'Multi' )]
        [Alias('service_category_ids')]
        [int32[]]$ServiceCategoryIDs,
        # Filters by the specified ITIL ticket type ID.
        [Parameter( ParameterSetName = 'Multi' )]
        [Alias('itil_ticket_type')]
        [int32]$ITILTicketType,
        # Include service status information in the result.
        [Parameter( ParameterSetName = 'Multi' )]
        [switch]$IncludeStatusInfo,
        # Include extra objects in the result.
        [Parameter( ParameterSetName = 'Single' )]
        [switch]$IncludeDetails
    )
    Invoke-HaloPreFlightCheck
    $CommandName = $MyInvocation.MyCommand.Name
    $Parameters = (Get-Command -Name $CommandName).Parameters
    # Workaround to prevent the query string processor from adding a ServiceID=' parameter by removing it from the set parameters.
    if ($ServiceID) {
        $Parameters.Remove('ServiceID') | Out-Null
    }
    try {
        if ($ServiceID) {
            Write-Verbose "Running in single-service mode because '-ServiceID' was provided."
            $QSCollection = New-HaloQuery -CommandName $CommandName -Parameters $Parameters
            $Resource = "api/service/$($ServiceID)"
            $RequestParams = @{
                Method = 'GET'
                Resource = $Resource
                AutoPaginateOff = $True
                QSCollection = $QSCollection
                ResourceType = 'services'
            }
        } else {
            Write-Verbose 'Running in multi-service mode.'
            $QSCollection = New-HaloQuery -CommandName $CommandName -Parameters $Parameters -IsMulti
            $Resource = 'api/service'
            $RequestParams = @{
                Method = 'GET'
                Resource = $Resource
                AutoPaginateOff = $Paginate
                QSCollection = $QSCollection
                ResourceType = 'services'
            }
        }
        $ServiceResults = New-HaloGETRequest @RequestParams
        Return $ServiceResults
    } catch {
        New-HaloError -ErrorRecord $_
    }
}