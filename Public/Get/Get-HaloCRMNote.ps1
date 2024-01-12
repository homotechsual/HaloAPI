#Requires -Version 7
function Get-HaloCRMNote {
    <#
        .SYNOPSIS
            Gets CRM notes from the Halo API. https://mjcoltd.halopsa.com/api/CRMNote?count=15&client_id=29&includehtmlnote=true&includeattachments=true
        .DESCRIPTION
            Retrieves CRM notes from the Halo API - supports a variety of filtering parameters.
        .OUTPUTS
            A powershell object containing the response.
    #>
    [CmdletBinding( DefaultParameterSetName = 'Multi' )]
    [OutputType([Object])]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', '', Justification = 'Uses dynamic parameter parsing.')]
    Param(
        # CRM note ID.
        [Parameter( ParameterSetName = 'Single', Mandatory = $True )]
        [int64]$CRMNoteID,
        # The number of CRM notes to return.
        [Parameter( ParameterSetName = 'Single' )]
        [Parameter( ParameterSetName = 'Multi' )]
        [int64]$Count,
        # Get CRM notes for a single client  with the specified ID.
        [Parameter( ParameterSetName = 'Multi', Mandatory = $True, ValueFromPipeline )]
        #[HaloPipelineIDArgumentTransformation()]
        [Alias('client_id')]
        [int]$ClientID,
        # Include the CRM note HTML in the response.
        [Parameter( ParameterSetName = 'Single' )]
        [Parameter( ParameterSetName = 'Multi' )]
        [switch]$IncludeHTMLNote,
        # Include attachment details in the response.
        [Parameter( ParameterSetName = 'Single' )]
        [Parameter( ParameterSetName = 'Multi' )]
        [switch]$IncludeAttachments
    )
    Invoke-HaloPreFlightCheck
    $CommandName = $MyInvocation.MyCommand.Name
    $Parameters = (Get-Command -Name $CommandName).Parameters
    # Workaround to prevent the query string processor from adding an 'crmnoteid=' parameter by removing it from the set parameters.
    if ($CRMNoteID) {
        $Parameters.Remove('CRMNoteID') | Out-Null
    }
    $QSCollection = New-HaloQuery -CommandName $CommandName -Parameters $Parameters
    try {
        if ($CRMNoteID) {
            Write-Verbose "Running in single-CRM-note mode because '-CRMNoteID' was provided."
            $Resource = "api/crmnote/$($CRMNoteID)"
        } else {
            Write-Verbose 'Running in multi-CRM-note mode.'
            $Resource = 'api/crmnote'
        }
        $RequestParams = @{
            Method = 'GET'
            Resource = $Resource
            AutoPaginateOff = $True
            QSCollection = $QSCollection
            ResourceType = 'actions'
        }
        $CRMNoteResults = New-HaloGETRequest @RequestParams
        Return $CRMNoteResults
    } catch {
        New-HaloError -ErrorRecord $_
    }
}