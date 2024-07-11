function Remove-HaloViewColumn {
    <#
        .SYNOPSIS
           Removes a viewcolumn from the Halo API.
        .DESCRIPTION
            Deletes a specific viewcolumn from Halo.
        .OUTPUTS
            A powershell object containing the response.
    #>
    [cmdletbinding( SupportsShouldProcess = $True, ConfirmImpact = 'High' )]
    [OutputType([Object])]
    Param(
        # The ViewColumn ID
        [Parameter( Mandatory, ParameterSetName = 'Single' )]
        [int64]$ViewColumnID,
        # Object containing viewcolumn id for batch processing.
        [Parameter( Mandatory, ParameterSetName = 'Batch')]
        [Object]$ViewColumn
    )
    Invoke-HaloPreFlightCheck
    try {
        if ($ViewColumn) {
            $ViewColumnID = $ViewColumn.Id
        }
        $ObjectToDelete = Get-HaloViewColumn -ViewColumnID $ViewColumnID
        if ($ObjectToDelete) {
            if ($PSCmdlet.ShouldProcess("ViewColumn '$($ObjectToDelete.id)'", 'Delete')) {
                $Resource = "api/viewcolumns/$($ViewColumnID)"
                $ViewColumnResults = New-HaloDELETERequest -Resource $Resource
                Return $ViewColumnResults
            }
        } else {
            Throw 'ViewColumn was not found in Halo to delete.'
        }
    } catch {
        New-HaloError -ErrorRecord $_
    }
}