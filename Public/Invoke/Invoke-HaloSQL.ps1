Function Invoke-HaloSQL {
    <#
        .SYNOPSIS
            Uses the Reports API endpoint to run arbitrary SQL.
        .DESCRIPTION
            Function to run a report preview with a SQL query parameter. Use -IncludeFullReport to get the entire report object instead of just the results
        .OUTPUTS
            Outputs an object containing the response from the web request.
    #>
    [CmdletBinding( SupportsShouldProcess = $True )]
    [OutputType([Object[]])]
    Param (
        # String or Here String for SQL Statement
        [Parameter( Mandatory = $True, ValueFromPipeline )]
        [String]$SQLQuery,
        # Return Full Report Object.
        [Parameter()]
        [Switch]$IncludeFullReport
    )
    Invoke-HaloPreFlightCheck
    try {
            $Payload = @(@{id = 0; name= ''; sql = $SQLQuery; apiquery_id = 0; "_testonly" = $false; "_loadreportonly" = $true})
            if ($PSCmdlet.ShouldProcess($Payload -is [Array] ? 'Reports' : 'Report', 'Execute')) {
                $Report = New-HaloPOSTRequest -Object $Payload -Endpoint 'report'
                if (-not $Report.report.load_error) {
                    
                    if ($Report.report.rows.count -eq 0) {
                        throw "No results were returned"
                    }
                    
                    else {    
                        if ($IncludeFullReport) {
                            return $Report
                        }
                        else {
                            return $Report.report.rows
                        }
                    }
                } else {
                    Throw $Report.report.load_error
                }
            }
            
    } catch {
        New-HaloError -ErrorRecord $_
    }
}
