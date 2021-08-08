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
    [CmdletBinding( DefaultParameterSetName = "Multi" )]
    Param(
        # Action ID.
        [Parameter( ParameterSetName = "Single", Mandatory = $True )]
        [int64]$ActionID,
        # The number of actions to return.
        [Parameter( ParameterSetName = "Multi" )]
        [int64]$Count,
        # Get actions for a single ticket with the specified ID.
        [Parameter( ParameterSetName = "Single", Mandatory = $True )]
        [Parameter( ParameterSetName = "Multi" )] # ?ACT Query with Halo why this is required.
        [Alias("ticket_id")]
        [int32]$TicketID,
        # Exclude system-performed actions.
        [Parameter( ParameterSetName = "Multi" )]
        [switch]$ExcludeSys,
        # Only get actions that are part of agent to end user conversations.
        [Parameter( ParameterSetName = "Multi" )]
        [switch]$ConversationOnly,
        # Only get actions performed by agents.
        [Parameter( ParameterSetName = "Single" )]
        [Parameter( ParameterSetName = "Multi" )]
        [switch]$AgentOnly,
        # Only get actions that involve suppliers.
        [Parameter(ParameterSetName = "Multi" )]
        [switch]$SupplierOnly,
        # Exclude private actions.
        [Parameter( ParameterSetName = "Multi" )]
        [switch]$ExcludePrivate,
        # Include the action note HTML in the response.
        [Parameter( ParameterSetName = "Multi" )]
        [switch]$IncludeHTMLNote,
        # Include the action email HTML in the response.
        [Parameter( ParameterSetName = "Multi" )]
        [switch]$IncludeHTMLEmail,
        # Include attachment details in the response.
        [Parameter( ParameterSetName = "Multi" )]
        [switch]$IncludeAttachments,
        # Only get important actions.
        [Parameter( ParameterSetName = "Multi" )]
        [switch]$ImportantOnly,
        # Only get SLA hold and release actions.
        [Parameter( ParameterSetName = "Multi" )]
        [switch]$SLAOnly,
        # Only get actions from child tickets.
        [Parameter( ParameterSetName = "Multi" )]
        [switch]$IsChildNotes,
        # Include the HTML and plain text email body in the response.
        [Parameter( ParameterSetName = "Single" )]
        [switch]$IncludeEmail,
        # Include extra detail objects.
        [Parameter( ParameterSetName = "Single" )]
        [switch]$IncludeDetails,
        # Ignore the '-ActionID' and get the most recent action for the '-TicketID'
        [Parameter( ParameterSetName = "Single" )]
        [switch]$MostRecent,
        # Only get email actions.
        [Parameter( ParameterSetName = "Single" )]
        [switch]$EmailOnly,
        # Exclude system-performed actions.
        [Parameter( ParameterSetName = "Single" )]
        [switch]$NonSystem
    )
    $CommandName = $MyInvocation.InvocationName
    $Parameters = (Get-Command -Name $CommandName).Parameters
    # Workaround to prevent the query string processor from adding an 'actionid=' parameter by removing it from the set parameters.
    if ($ActionID) {
        $Parameters.Remove("ActionID") | Out-Null
    }
    $QueryString = New-HaloQueryString -CommandName $CommandName -Parameters $Parameters
    try {
        if ($ActionID) {
            Write-Verbose "Running in single-action mode because '-ActionID' was provided."
            $Resource = "api/Actions/$($ActionID)$($QueryString)"
        } else {
            Write-Verbose "Running in multi-action mode."
            $Resource = "api/Actions$($QueryString)"
        }
        $RequestParams = @{
            Method = "GET"
            Resource = $Resource
        }
        $ActionResults = Invoke-HaloRequest @RequestParams
        Return $ActionResults
    } catch {
        Write-Error "Failed to get actions from the Halo API. You'll see more detail if using '-Verbose'"
        Write-Verbose "$_"
    }
}