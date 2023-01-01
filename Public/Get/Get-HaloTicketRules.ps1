#Requires -Version 7
function Get-HaloTicketRules {
    <#
        .SYNOPSIS
            Gets Halo Ticket Rules information from the Halo API.
        .DESCRIPTION
            Retrieves Ticket Rule from the Halo API. By default it retrieves global rules AND workflow step rules. Use "-ExcludeWorkflow" to limit the list to only Global Rules.
        .OUTPUTS
            A powershell object containing the response.
    #>
    [CmdletBinding( DefaultParameterSetName = 'Multi' )]
    [OutputType([Object])]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', '', Justification = 'Uses dynamic parameter parsing.')]
    Param(
        # Rule ID
        [Parameter( ParameterSetName = 'Single', Mandatory = $True )]
        [int64]$RuleID,
        [Parameter( ParameterSetName = 'Single' )]
        [switch]$IncludeDetails,
        [Parameter( ParameterSetName = 'Single' )]
        [switch]$IncludeCriteriaInfo,
        # Include Workflow Step Rules
        [Parameter( ParameterSetName = 'Multi')]
        [switch]$ExcludeWorkflow,
        # ShowAll
        [Parameter( ParameterSetName = 'Multi' )]
        [switch]$ShowAll
    )
    Invoke-HaloPreFlightCheck
    $CommandName = $MyInvocation.MyCommand.Name
    $Parameters = (Get-Command -Name $CommandName).Parameters
    # Workaround to prevent the query string processor from adding a 'RuleID=' parameter by removing it from the set parameters.
    if ($RuleID) {
        $Parameters.Remove('RuleID') | Out-Null
    }


    $QSCollection = New-HaloQuery -CommandName $CommandName -Parameters $Parameters
    try {
        if ($RuleID) {
            Write-Verbose "Running in single-field mode because '-RuleID' was provided."
            $Resource = "api/TicketRules/$($RuleID)"
        } else {
            Write-Verbose 'Running in multi-field mode.'
            $Resource = 'api/TicketRules'
        }
        $RequestParams = @{
            Method = 'GET'
            Resource = $Resource
            AutoPaginateOff = $True
            QSCollection = $QSCollection
            #ResourceType = 'categories'
        }
        $RuleResults = New-HaloGETRequest @RequestParams
        Return $RuleResults
    } catch {
        New-HaloError -ErrorRecord $_
    }
}
