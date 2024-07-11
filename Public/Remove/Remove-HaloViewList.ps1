function Remove-HaloViewList {
    <#
        .SYNOPSIS
           Removes a viewlist from the Halo API.
        .DESCRIPTION
            Deletes a specific viewlist from Halo.
        .OUTPUTS
            A powershell object containing the response.
    #>
    [cmdletbinding( SupportsShouldProcess = $True, ConfirmImpact = 'High' )]
    [OutputType([Object])]
    Param(
        # The ViewList ID
        [Parameter( Mandatory, ParameterSetName = 'Single' )]
        [int64]$ViewListID,
        # Object containing viewlist id for batch processing.
        [Parameter( Mandatory, ParameterSetName = 'Batch')]
        [Object]$ViewList
    )
    Invoke-HaloPreFlightCheck
    try {
        if ($ViewList) {
            $ViewListID = $ViewList.Id
        }
        $ObjectToDelete = Get-HaloViewList -ViewListID $ViewListID
        if ($ObjectToDelete) {
            if ($PSCmdlet.ShouldProcess("ViewList '$($ObjectToDelete.id)'", 'Delete')) {
                $Resource = "api/viewlists/$($ViewListID)"
                $ViewListResults = New-HaloDELETERequest -Resource $Resource
                Return $ViewListResults
            }
        } else {
            Throw 'ViewList was not found in Halo to delete.'
        }
    } catch {
        New-HaloError -ErrorRecord $_
    }
}