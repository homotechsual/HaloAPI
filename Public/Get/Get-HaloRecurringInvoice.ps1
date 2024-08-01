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
        # The advanced search query to use.
        [Parameter( ParameterSetName = 'Multi' )]
        [Alias('advanced_search')]
        [string]$AdvancedSearch,
        # Filter by an asset id.
        [Parameter( ParameterSetName = 'Multi' )]
        [Alias('asset_id')]
        [int32]$AssetId,
        # Filter for recurring invoices awaiting approval.
        [Parameter( ParameterSetName = 'Multi' )]
        [Alias('awaiting_approval')]
        [switch]$AwaitingApproval,
        # Filter by billing date.
        [Parameter( ParameterSetName = 'Multi' )]
        [Alias('billing_date')]
        [datetime]$BillingDate,
        # Filter by billing category ids.
        [Parameter( ParameterSetName = 'Multi' )]
        [Alias('billingcategory_ids')]
        [Int32[]]$BillingCategoryIds,
        # Filter by the specified client id.
        [Parameter( ParameterSetName = 'Multi' )]
        [Alias('client_id')]
        [int32]$ClientId,
        # Filter by the specified client ids.
        [Parameter( ParameterSetName = 'Multi' )]
        [Alias('client_ids')]
        [int32[]]$ClientIds,
        # Filter by contract id.
        [Parameter( ParameterSetName = 'Multi' )]
        [Alias('contract_id')]
        [int32]$ContractId,
        # The number of invoices to return if not using pagination.
        [Parameter( ParameterSetName = 'Multi' )]
        [int32]$Count,
        # Return recurring invoice ids only.
        [Parameter( ParameterSetName = 'Multi' )]
        [switch]$IdOnly,
        # Include credit notes
        [Parameter( ParameterSetName = 'Multi' )]
        [switch]$IncludeCredits,
        # Include invoices
        [Parameter( ParameterSetName = 'Multi' )]
        [switch]$IncludeInvoices,
        # Include invoice lines
        [Parameter( ParameterSetName = 'Multi' )]
        [switch]$IncludeLines,
        # Include PO invoices.
        [Parameter( ParameterSetName = 'Multi' )]
        [switch]$IncludePOInvoices,
        # Include the field `invoicedateend` in the results.
        [Parameter( ParameterSetName = 'Multi' )]
        [Alias('invoicedateend')]
        [switch]$IncludeInvoiceDateEnd,
        # Include the field `invoicedatestart` in the results.
        [Parameter( ParameterSetName = 'Multi' )]
        [Alias('invoicedatestart')]
        [switch]$IncludeInvoiceDateStart,
        # Filter by your approvals.
        [Parameter( ParameterSetName = 'Multi' )]
        [Alias('my_approvals')]
        [switch]$MyApprovals,
        # Filter for unposted invoices only.
        [Parameter( ParameterSetName = 'Multi' )]
        [switch]$NotPostedOnly,
        # First field to order the results by.
        [Parameter( ParameterSetName = 'Multi' )]
        [string]$Order,
        # Order results for the first field in descending order (respects the field choice in '-OrderBy')
        [Parameter( ParameterSetName = 'Multi' )]
        [switch]$OrderDesc,
        # Second field to order the results by.
        [Parameter( ParameterSetName = 'Multi' )]
        [string]$Order2,
        # Order results for the second field in descending order (respects the field choice in '-OrderBy2')
        [Parameter( ParameterSetName = 'Multi' )]
        [switch]$OrderDesc2,
        # Third field to order the results by.
        [Parameter( ParameterSetName = 'Multi' )]
        [string]$Order3,
        # Order results for the third field in descending order (respects the field choice in '-OrderBy3')
        [Parameter( ParameterSetName = 'Multi' )]
        [switch]$OrderDesc3,
        # Fourth field to order the results by.
        [Parameter( ParameterSetName = 'Multi' )]
        [string]$Order4,
        # Order results for the fourth field in descending order (respects the field choice in '-OrderBy4')
        [Parameter( ParameterSetName = 'Multi' )]
        [switch]$OrderDesc4,
        # Fifth field to order the results by.
        [Parameter( ParameterSetName = 'Multi' )]
        [string]$Order5,
        # Order results for the fifth field in descending order (respects the field choice in '-OrderBy5')
        [Parameter( ParameterSetName = 'Multi' )]
        [switch]$OrderDesc5,
        # Which page to return.
        [Parameter( ParameterSetName = 'Multi' )]
        [Alias('page_no')]
        [int32]$PageNo,
        # Number of results per page.
        [Parameter( ParameterSetName = 'Multi' )]
        [Alias('page_size')]
        [int32]$PageSize,
        # Paginate results
        [Parameter( ParameterSetName = 'Multi' )]
        [Alias('pageinate')]
        [switch]$Paginate,
        # Filter by the specified payment statuses.
        [Parameter( ParameterSetName = 'Multi' )]
        [int32[]]$PaymentStatuses,
        # Include posted invoices only.
        [Parameter( ParameterSetName = 'Multi' )]
        [switch]$PostedOnly,
        # Filter by the specified purchase order id.
        [Parameter( ParameterSetName = 'Multi' )]
        [Alias('purchaseorder_id')]
        [int32]$PurchaseOrderId,
        # Filter by the specified quote statuses.
        [Parameter( ParameterSetName = 'Multi' )]
        [Alias('quote_status')]
        [string[]]$QuoteStatuses,
        # Filter by whether the recurring invoice is marked 'ready for invoicing'.
        [Parameter( ParameterSetName = 'Multi' )]
        [Alias('ready_for_invoicing')]
        [switch]$ReadyForInvoicing,
        # Filter for invoices marked 'review required'.
        [Parameter( ParameterSetName = 'Multi' )]
        [switch]$ReviewRequired,
        # Filter by recurring invoice type. Valid values are 'contracts', 'invoices' or 'both'.
        [Parameter( ParameterSetName = 'Multi' )]
        [Alias('rinvoice_type')]
        [ValidateSet('contracts', 'invoices', 'both')]
        [string]$RecurringInvoiceType,
        # Filter by contract sales order id.
        [Parameter( ParameterSetName = 'Multi' )]
        [Alias('salesorder_id')]
        [int32]$SalesOrderId,
        # Filter using the specified search query.
        [Parameter( ParameterSetName = 'Multi' )]
        [string]$Search,
        # Filter by sent status.
        [Parameter( ParameterSetName = 'Multi' )]
        [Alias('sent_status')]
        [int]$SentStatus,
        # Filter by the specified site id.
        [Parameter( ParameterSetName = 'Multi' )]
        [Alias('site_id')]
        [int32]$SiteId,
        # Filter by invoices requiring stripe payment.
        [Parameter( ParameterSetName = 'Multi' )]
        [switch]$StripeAutoPaymentRequired,
        # Filter by the specified ticket id.
        [Parameter( ParameterSetName = 'Multi' )]
        [Alias('ticket_id')]
        [int32]$TicketId,
        # Filter by the specified top level id.
        [Parameter( ParameterSetName = 'Multi' )]
        [Alias('toplevel_id')]
        [int32]$TopLevelId,
        # Filter by the specified user ID.
        [Parameter( ParameterSetName = 'Multi' )]
        [Alias('user_id')]
        [int32]$UserId,
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