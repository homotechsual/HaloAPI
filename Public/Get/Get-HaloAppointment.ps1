#Requires -Version 7
function Get-HaloAppointment {
    <#
        .SYNOPSIS
            Gets appointments from the Halo API.
        .DESCRIPTION
            Retrieves appointments from the Halo API - supports a variety of filtering parameters.
        .OUTPUTS
            A powershell object containing the response.
    #>
    [CmdletBinding( DefaultParameterSetName = 'Multi' )]
    [OutputType([Object])]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', '', Justification = 'Uses dynamic parameter parsing.')]
    Param(
        # Appointment ID
        [Parameter( ParameterSetName = 'Single', Mandatory = $True )]
        [int64]$AppointmentID,
        # Admin override to return all appointments
        [Parameter( ParameterSetName = 'Multi' )]
        [switch]$ShowAll,
        # Return appointments with a start date greater than this value.
        [Parameter( ParameterSetName = 'Multi' )]
        [Alias('start_date')]
        [string]$StartDate,
        # Return appointments with an end date greater than this value
        [Parameter( ParameterSetName = 'Multi' )]
        [Alias('end_date')]
        [string]$EndDate,
        # Comma separated list of agent IDs. Returns these agent's appointments
        [Parameter( ParameterSetName = 'Multi' )]
        [string]$Agents,
        # Include the appointment type 'holiday' in the response
        [Parameter( ParameterSetName = 'Multi' )]
        [switch]$ShowHolidays,
        # Include projects in the response
        [Parameter( ParameterSetName = 'Multi' )]
        [switch]$ShowProjects,
        # Include change requests in the response
        [Parameter( ParameterSetName = 'Multi' )]
        [switch]$ShowChanges,
        # Include appointments in the response
        [Parameter( ParameterSetName = 'Multi' )]
        [switch]$ShowAppointments,
        # Return appointments like this search string
        [Parameter( ParameterSetName = 'Multi' )]
        [string]$Search,
        # Only return appointments in the response
        [Parameter( ParameterSetName = 'Multi' )]
        [switch]$AppointmentsOnly,
        # Only return tasks in the response
        [Parameter( ParameterSetName = 'Multi' )]
        [switch]$TasksOnly,
        # Exclude completed appointments from the response
        [Parameter( ParameterSetName = 'Multi' )]
        [switch]$HideCompleted,
        # Return appointments assigned to a particular ticket
        [Parameter( ParameterSetName = 'Multi' )]
        [Alias('ticket_id')]
        [int64]$TicketID,
        # Whether to include extra objects in the response
        [Parameter( ParameterSetName = 'Single' )]
        [switch]$IncludeDetails
    )
    Invoke-HaloPreFlightCheck
    $CommandName = $MyInvocation.MyCommand.Name
    $Parameters = (Get-Command -Name $CommandName).Parameters
    # Workaround to prevent the query string processor from adding a 'appointmentid=' parameter by removing it from the set parameters.
    if ($AppointmentID) {
        $Parameters.Remove('AppointmentID') | Out-Null
    }
    $QSCollection = New-HaloQuery -CommandName $CommandName -Parameters $Parameters
    try {
        if ($AppointmentID) {
            Write-Verbose "Running in single-appointment mode because '-AppointmentID' was provided."
            $Resource = "api/Appointment/$($AppointmentID)"
        } else {
            Write-Verbose 'Running in multi-appointment mode.'
            $Resource = 'api/Appointment'
        }    
        $RequestParams = @{
            Method = 'GET'
            Resource = $Resource
            AutoPaginateOff = $True
            QSCollection = $QSCollection
            ResourceType = 'appointments'
        }
        $AppointmentResults = New-HaloGETRequest @RequestParams
        Return $AppointmentResults
    } catch {
        New-HaloError -ErrorRecord $_
    }
}