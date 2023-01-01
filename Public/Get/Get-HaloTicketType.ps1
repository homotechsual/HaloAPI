#Requires -Version 7
function Get-HaloTicketType {
    <#
        .SYNOPSIS
            Gets ticket types from the Halo API.
        .DESCRIPTION
            Retrieves ticket types from the Halo API - supports a variety of filtering parameters.
        .OUTPUTS
            A powershell object containing the response.
    #>
    [CmdletBinding( DefaultParameterSetName = 'Multi' )]
    [OutputType([Object])]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', '', Justification = 'Uses dynamic parameter parsing.')]
    Param(
        # Ticket Type ID
        [Parameter( ParameterSetName = 'Single', Mandatory = $True )]
        [int64]$TicketTypeID,
        # Show the count of tickets in the results.
        [Parameter( ParameterSetName = 'Multi' )]
        [switch]$ShowCounts,
        # Filter counts to a specific domain: reqs = tickets, opps = opportunities and prjs = projects.
        [Parameter( ParameterSetName = 'Multi' )]
        [ValidateSet(
            'reqs',
            'opps',
            'prjs'
        )]
        [string]$Domain,
        # Filter counts to a specific view ID.
        [Parameter( ParameterSetName = 'Multi' )]
        [Alias('view_id')]
        [int32]$ViewID,
        # Include inactive ticket types in the results.
        [Parameter( ParameterSetName = 'Multi' )]
        [switch]$ShowInactive,
        # Filter by a specific client id.
        [Parameter( ParameterSetName = 'Multi' )]
        [Alias('client_id')]
        [int32]$ClientID,
        # Include extra objects in the result.
        [Parameter( ParameterSetName = 'Single' )]
        [Switch]$IncludeDetails,
        # Include all related configuration in the result.
        [Parameter( ParameterSetName = 'Single' )]
        [Switch]$IncludeConfig
    )
    Invoke-HaloPreFlightCheck
    $CommandName = $MyInvocation.MyCommand.Name
    $Parameters = (Get-Command -Name $CommandName).Parameters
    # Workaround to prevent the query string processor from adding a 'tickettypeid=' parameter by removing it from the set parameters.
    if ($TicketTypeID) {
        $Parameters.Remove('TicketTypeID') | Out-Null
    }
    $QSCollection = New-HaloQuery -CommandName $CommandName -Parameters $Parameters
    try {
        if ($TicketTypeID) {
            Write-Verbose "Running in single-ticket-type mode because '-TicketTypeID' was provided."
            $Resource = "api/tickettype/$($TicketTypeID)"
        } else {
            Write-Verbose 'Running in multi-ticket-type mode.'
            $Resource = 'api/tickettype'
        }
        $RequestParams = @{
            Method = 'GET'
            Resource = $Resource
            AutoPaginateOff = $True
            QSCollection = $QSCollection
            ResourceType = 'tickettypes'
        }
        $TicketTypeResults = New-HaloGETRequest @RequestParams
        Return $TicketTypeResults
    } catch {
        New-HaloError -ErrorRecord $_
    }
}
