function Remove-HaloCustomTableData {
    <#
        .SYNOPSIS
           Removes custom table data from the Halo API.
        .DESCRIPTION
            Deletes custom table data from Halo by posting a CustomTable payload with delete flags.
        .OUTPUTS
            A powershell object containing the response.
    #>
    [cmdletbinding( SupportsShouldProcess = $True, ConfirmImpact = 'High' )]
    [OutputType([Object])]
    Param(
        # The custom table ID.
        [Parameter( Mandatory = $True )]
        [int64]$CustomTableID,
        # Deletes all data for the custom table.
        [Parameter()]
        [switch]$AllData,
        # Optional start date for data deletion.
        [Parameter()]
        [datetime]$StartDate,
        # Optional end date for data deletion.
        [Parameter()]
        [datetime]$EndDate
    )
    Invoke-HaloPreFlightCheck
    try {
        if (-not $AllData -and (-not $PSBoundParameters.ContainsKey('StartDate') -or -not $PSBoundParameters.ContainsKey('EndDate'))) {
            throw 'Specify -AllData or provide both -StartDate and -EndDate.'
        }

        $Payload = @{
            id = $CustomTableID
            _delete_data = $True
        }

        if (-not $AllData) {
            $Payload['_delete_data_start_date'] = $StartDate
            $Payload['_delete_data_end_date'] = $EndDate
        }

        if ($PSCmdlet.ShouldProcess(('Custom Table ''{0}'' data' -f $CustomTableID), 'Delete')) {
            $CustomTableDataResults = New-HaloPOSTRequest -Object ([pscustomobject]$Payload) -Endpoint 'customtable'
            Return $CustomTableDataResults
        }
    } catch {
        New-HaloError -ErrorRecord $_
    }
}