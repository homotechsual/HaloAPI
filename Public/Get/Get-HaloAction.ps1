#using module ..\..\Classes\Transformations\HaloPipelineIDArgumentTransformation.psm1
#Requires -Version 7
function Get-HaloAction {
    <#
        .SYNOPSIS
            Gets actions from the Halo API.
        .DESCRIPTION
            Retrieves actions from the Halo API - supports a variety of filtering parameters.
        .OUTPUTS
            A powershell object containing the response.
    #>
    [CmdletBinding( DefaultParameterSetName = 'Multi' )]
    [OutputType([Object])]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', '', Justification = 'Uses dynamic parameter parsing.')]
    Param(
        # Action ID.
        [Parameter( ParameterSetName = 'Single', Mandatory = $True )]
        [int64]$ActionID,
        # The number of actions to return.
        [Parameter( ParameterSetName = 'Multi' )]
        [int64]$Count,
        # Get actions for a single ticket with the specified ID.
        [Parameter( ParameterSetName = 'Single', Mandatory = $True, ValueFromPipeline )]
        [Parameter( ParameterSetName = 'Multi', Mandatory = $True, ValueFromPipeline )]
        #[HaloPipelineIDArgumentTransformation()]
        [Alias('ticket_id')]
        [int]$TicketID,
        # Exclude system-performed actions.
        [Parameter( ParameterSetName = 'Multi' )]
        [switch]$ExcludeSys,
        # Only get actions that are part of agent to end user conversations.
        [Parameter( ParameterSetName = 'Multi' )]
        [switch]$ConversationOnly,
        # Only get actions performed by agents.
        [Parameter( ParameterSetName = 'Single' )]
        [Parameter( ParameterSetName = 'Multi' )]
        [switch]$AgentOnly,
        # Only get actions that involve suppliers.
        [Parameter(ParameterSetName = 'Multi' )]
        [switch]$SupplierOnly,
        # Exclude private actions.
        [Parameter( ParameterSetName = 'Multi' )]
        [switch]$ExcludePrivate,
        # Include the action note HTML in the response.
        [Parameter( ParameterSetName = 'Multi' )]
        [switch]$IncludeHTMLNote,
        # Include the action email HTML in the response.
        [Parameter( ParameterSetName = 'Multi' )]
        [switch]$IncludeHTMLEmail,
        # Include attachment details in the response.
        [Parameter( ParameterSetName = 'Multi' )]
        [switch]$IncludeAttachments,
        # Only get important actions.
        [Parameter( ParameterSetName = 'Multi' )]
        [switch]$ImportantOnly,
        # Only get SLA hold and release actions.
        [Parameter( ParameterSetName = 'Multi' )]
        [switch]$SLAOnly,
        # Only get actions from child tickets.
        [Parameter( ParameterSetName = 'Multi' )]
        [switch]$IsChildNotes,
        # Include the HTML and plain text email body in the response.
        [Parameter( ParameterSetName = 'Single' )]
        [switch]$IncludeEmail,
        # Include extra detail objects.
        [Parameter( ParameterSetName = 'Single' )]
        [switch]$IncludeDetails,
        # Ignore the '-ActionID' and get the most recent action for the '-TicketID'
        [Parameter( ParameterSetName = 'Single' )]
        [switch]$MostRecent,
        # Only get email actions.
        [Parameter( ParameterSetName = 'Single' )]
        [switch]$EmailOnly,
        # Exclude system-performed actions.
        [Parameter( ParameterSetName = 'Single' )]
        [switch]$NonSystem
    )
    Invoke-HaloPreFlightCheck
    $CommandName = $MyInvocation.MyCommand.Name
    $Parameters = (Get-Command -Name $CommandName).Parameters
    # Workaround to prevent the query string processor from adding an 'actionid=' parameter by removing it from the set parameters.
    if ($ActionID) {
        $Parameters.Remove('ActionID') | Out-Null
    }
    $QSCollection = New-HaloQuery -CommandName $CommandName -Parameters $Parameters
    try {
        if ($ActionID) {
            Write-Verbose "Running in single-action mode because '-ActionID' was provided."
            $Resource = "api/actions/$($ActionID)"
        } else {
            Write-Verbose 'Running in multi-action mode.'
            $Resource = 'api/actions'
        }
        $RequestParams = @{
            Method = 'GET'
            Resource = $Resource
            AutoPaginateOff = $True
            QSCollection = $QSCollection
            ResourceType = 'actions'
        }
        $ActionResults = New-HaloGETRequest @RequestParams
        Return $ActionResults
    } catch {
        New-HaloError -ErrorRecord $_
    }
}