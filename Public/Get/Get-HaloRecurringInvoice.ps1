#Requires -Version 7
function Get-HaloRecurringInvoice {
    <#
        .SYNOPSIS
            Gets recurring invoices from the Halo API.
        .DESCRIPTION
            Retrieves recurring invoices from the Halo API - supports a variety of filtering parameters.
        .OUTPUTS
            A powershell object containing the response.
    #>
    [CmdletBinding( DefaultParameterSetName = 'Multi' )]
    [OutputType([Object])]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', '', Justification = 'Uses dynamic parameter parsing.')]
    Param(
        # Invoice ID
        [Parameter( ParameterSetName = 'Single', Mandatory = $True )]
        [int64]$RecurringInvoiceID,
        # The number of invoices to return if not using pagination.
        [Parameter( ParameterSetName = 'Multi' )]
        [int32]$Count,
        # Return contracts matching the search term in the results.
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
        # First field to order the results by.
        [Parameter( ParameterSetName = 'Multi' )]
        [string]$OrderBy,
        # Order results for the first field in descending order (respects the field choice in '-OrderBy')
        [Parameter( ParameterSetName = 'Multi' )]
        [switch]$OrderByDesc,
        # Second field to order the results by.
        [Parameter( ParameterSetName = 'Multi' )]
        [string]$OrderBy2,
        # Order results for the second field in descending order (respects the field choice in '-OrderBy2')
        [Parameter( ParameterSetName = 'Multi' )]
        [switch]$OrderByDesc2,
        # Third field to order the results by.
        [Parameter( ParameterSetName = 'Multi' )]
        [string]$OrderBy3,
        # Order results for the third field in descending order (respects the field choice in '-OrderBy3')
        [Parameter( ParameterSetName = 'Multi' )]
        [switch]$OrderByDesc3,
        # Fourth field to order the results by.
        [Parameter( ParameterSetName = 'Multi' )]
        [string]$OrderBy4,
        # Order results for the fourth field in descending order (respects the field choice in '-OrderBy4')
        [Parameter( ParameterSetName = 'Multi' )]
        [switch]$OrderByDesc4,
        # Fifth field to order the results by.
        [Parameter( ParameterSetName = 'Multi' )]
        [string]$OrderBy5,
        # Order results for the fifth field in descending order (respects the field choice in '-OrderBy5')
        [Parameter( ParameterSetName = 'Multi' )]
        [switch]$OrderByDesc5,
        # Include inactive records
        [Parameter( ParameterSetName = 'Multi' )]
        [switch]$includeinactive,
        # Include invoices
        [Parameter( ParameterSetName = 'Multi' )]
        [switch]$includeinvoices,
        # Include credit notes
        [Parameter( ParameterSetName = 'Multi' )]
        [switch]$includecredits,
        # Include invoice lines
        [Parameter( ParameterSetName = 'Multi' )]
        [switch]$includeLines,
        # Include invoice Details
        [Parameter( ParameterSetName = 'Single' )]
        [switch]$includeDetails,
        # Filter by the specified ticket ID.
        [Parameter( ParameterSetName = 'Multi' )]
        [Alias('ticket_id')]
        [int32]$TicketID,
        # Filter by the specified client ID.
        [Parameter( ParameterSetName = 'Multi' )]
        [Alias('client_id')]
        [int32]$ClientID,
        # Filter by the specified site ID.
        [Parameter( ParameterSetName = 'Multi' )]
        [Alias('site_id')]
        [int32]$SiteID,
        # Filter by the specified user ID.
        [Parameter( ParameterSetName = 'Multi' )]
        [Alias('user_id')]
        [int32]$UserID,
        # Parameter to return the complete objects.
        [Parameter( ParameterSetName = 'Multi' )]
        [switch]$FullObjects
    )
    Invoke-HaloPreFlightCheck
    $CommandName = $MyInvocation.MyCommand.Name
    $Parameters = (Get-Command -Name $CommandName).Parameters
    # Workaround to prevent the query string processor from adding a 'recurringinvoiceid=' parameter by removing it from the set parameters.
    if ($RecurringInvoiceID) {
        $Parameters.Remove('RecurringInvoiceID') | Out-Null
    }
    # Similarly we don't want a `fullobjects=` parameter
    if ($FullObjects) {
        $Parameters.Remove('FullObjects') | Out-Null
    }
    try {
        if ($RecurringInvoiceID) {
            Write-Verbose "Running in single-invoice mode because '-RecurringInvoiceID' was provided."
            $QSCollection = New-HaloQuery -CommandName $CommandName -Parameters $Parameters
            $Resource = "api/RecurringInvoice/$($RecurringInvoiceID)"
            $RequestParams = @{
                Method = 'GET'
                Resource = $Resource
                AutoPaginateOff = $True
                QSCollection = $QSCollection
                ResourceType = 'invoices'
            }
        } else {
            Write-Verbose 'Running in multi-invoice mode.'
            $QSCollection = New-HaloQuery -CommandName $CommandName -Parameters $Parameters -IsMulti
            $Resource = 'api/RecurringInvoice'
            $RequestParams = @{
                Method = 'GET'
                Resource = $Resource
                AutoPaginateOff = $Paginate
                QSCollection = $QSCollection
                ResourceType = 'invoices'
            }
        }
        $InvoiceResults = New-HaloGETRequest @RequestParams
        # Fetch the complete details for each ticket
        if ($FullObjects) {
            $AllTicketResults = $InvoiceResults | ForEach-Object {             
                Get-HaloRecurringInvoice -RecurringInvoiceID $_.id
            }
            $InvoiceResults = $AllTicketResults
        }
        Return $InvoiceResults
    } catch {
        New-HaloError -ErrorRecord $_
    }
}