#Requires -Version 7
function Get-HaloTimesheet {
    <#
        .SYNOPSIS
            Gets timesheets from the Halo API.
        .DESCRIPTION
            Retrieves timesheets from the Halo API - supports a variety of filtering parameters.
        .OUTPUTS
            A powershell object containing the response.
    #>
    [CmdletBinding( DefaultParameterSetName = "Multi" )]
    Param(
        # Return the timesheet for the specified team.
        [Parameter( ParameterSetName = "Multi" )]
        [int32]$SelectedTeam,
        # Include holidays in the result.
        [Parameter( ParameterSetName = "Multi" )]
        [switch]$ShowHolidays,
        # Return the timesheet for the selected agents.
        [Parameter( ParameterSetName = "Multi" )]
        [int32[]]$SelectedAgents,
        # Return the selected types.
        [Parameter( ParameterSetName = "Multi" )]
        [int32[]]$SelectedTypes = @(0,1,2,3),
        # Timesheet start date/time.
        [Parameter( ParameterSetName = "Multi" )]
        [Alias("start_date")]
        [datetime]$StartDate,
        # Timesheet end date/time.
        [Parameter( ParameterSetName = "Multi" )]
        [Alias("end_date")]
        [datetime]$EndDate,
        # Include all days in the result.
        [Parameter( ParameterSetName = "Multi" )]
        [switch]$ShowAllDates,
        # Include all timesheet fields in the result.
        [Parameter( ParameterSetName = "Multi" )]
        [switch]$IncludeTimesheetFields,
        # The UTC offset.
        [Parameter( ParameterSetName = "Multi" )]
        [int32]$UTCOffset
    )
    $CommandName = $MyInvocation.InvocationName
    $Parameters = (Get-Command -Name $CommandName).Parameters
    try {
        $QSCollection = New-HaloQueryString -CommandName $CommandName -Parameters $Parameters -IsMulti -CommaSeparatedArrays
        $Resource = "api/timesheet"
        $RequestParams = @{
            Method = "GET"
            Resource = $Resource
            AutoPaginateOff = $True
            QSCollection = $QSCollection
            ResourceType = "timesheets"
        }
        $ReleaseResults = New-HaloRequest @RequestParams
        Return $ReleaseResults
    } catch {
        Write-Error "Failed to get timesheets from the Halo API. You'll see more detail if using '-Verbose'"
        Write-Verbose "$_"
    }
}