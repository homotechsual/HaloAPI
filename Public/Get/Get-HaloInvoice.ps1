#Requires -Version 7
function Get-HaloInvoice {
    <#
        .SYNOPSIS
            Gets invoices from the Halo API.
        .DESCRIPTION
            Retrieves invoices from the Halo API - supports a variety of filtering parameters.
        .OUTPUTS
            A powershell object containing the response.
    #>
    [CmdletBinding( DefaultParameterSetName = 'Multi' )]
    [OutputType([Object])]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', '', Justification = 'Uses dynamic parameter parsing.')]
    Param(
        # Invoice ID
        [Parameter( ParameterSetName = 'Single', Mandatory = $True )]
        [int64]$InvoiceID,
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
        # Filter for posted invoices only.
        [Parameter( ParameterSetName = 'Multi' )]
        [switch]$PostedOnly,
        # Filter for non-posted invoices only.
        [Parameter( ParameterSetName = 'Multi' )]
        [switch]$NotPostedOnly,
        # Filter by payment status. Provide a string separated by HTML encoded commas.
        [Parameter( ParameterSetName = 'Multi' )]
        [string]$PaymentStatuses,
        # Filter by payment status. Provide an array of integers.
        [Parameter( ParameterSetName = 'Multi' )]
        [int64[]]$PaymentStatusIds
    )
    Invoke-HaloPreFlightCheck
    $CommandName = $MyInvocation.MyCommand.Name
    $Parameters = (Get-Command -Name $CommandName).Parameters
    # Workaround to prevent the query string processor from adding a 'invoiceid=' parameter by removing it from the set parameters.
    if ($InvoiceID) {
        $Parameters.Remove('InvoiceID') | Out-Null
    }
    # Transform the payment statuses parameter to a HTML encoded string.
    if ($PaymentStatusIds) {
        Write-Verbose 'Converting Payment Status IDs to a string.'
        $Parameters.Remove('PaymentStatusIds') | Out-Null
        [string]$PaymentStatuses = $PaymentStatusIds -join ','
    }
    Write-Verbose ('Payment Statuses parameter type is {0}' -f $PaymentStatuses.GetType().Name)
    Write-Verbose ('Payment Statuses parameter value is {0}' -f $PaymentStatuses)
    try {
        if ($InvoiceID) {
            Write-Verbose "Running in single-invoice mode because '-InvoiceID' was provided."
            $QSCollection = New-HaloQuery -CommandName $CommandName -Parameters $Parameters
            $Resource = "api/invoice/$($InvoiceID)"
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
            $Resource = 'api/invoice'
            $RequestParams = @{
                Method = 'GET'
                Resource = $Resource
                AutoPaginateOff = $Paginate
                QSCollection = $QSCollection
                ResourceType = 'invoices'
            }
        }
        $InvoiceResults = New-HaloGETRequest @RequestParams
        Return $InvoiceResults
    } catch {
        New-HaloError -ErrorRecord $_
    }
}