function Remove-HaloViewListGroup {
    <#
        .SYNOPSIS
           Removes a viewlistgroup from the Halo API.
        .DESCRIPTION
            Deletes a specific viewlistgroup from Halo.
        .OUTPUTS
            A powershell object containing the response.
    #>
    [cmdletbinding( SupportsShouldProcess = $True, ConfirmImpact = 'High' )]
    [OutputType([Object])]
    Param(
        # The ViewListGroup ID
        [Parameter( Mandatory, ParameterSetName = 'Single' )]
        [int64]$ViewListGroupID,
        # Object containing viewlistgroup id for batch processing.
        [Parameter( Mandatory, ParameterSetName = 'Batch')]
        [Object]$ViewListGroup
    )
    Invoke-HaloPreFlightCheck
    try {
        if ($ViewListGroup) {
            $ViewListGroupID = $ViewListGroup.Id
        }
        $ObjectToDelete = Get-HaloViewListGroup -ViewListGroupID $ViewListGroupID
        if ($ObjectToDelete) {
            if ($PSCmdlet.ShouldProcess("ViewListGroup '$($ObjectToDelete.id)'", 'Delete')) {
                $Resource = "api/viewlistgroup/$($ViewListGroupID)"
                $ViewListGroupResults = New-HaloDELETERequest -Resource $Resource
                Return $ViewListGroupResults
            }
        } else {
            Throw 'ViewListGroup was not found in Halo to delete.'
        }
    } catch {
        New-HaloError -ErrorRecord $_
    }
}