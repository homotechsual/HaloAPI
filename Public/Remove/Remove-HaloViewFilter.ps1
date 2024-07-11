function Remove-HaloViewFilter {
    <#
        .SYNOPSIS
           Removes a viewfilter from the Halo API.
        .DESCRIPTION
            Deletes a specific viewfilter from Halo.
        .OUTPUTS
            A powershell object containing the response.
    #>
    [cmdletbinding( SupportsShouldProcess = $True, ConfirmImpact = 'High' )]
    [OutputType([Object])]
    Param(
        # The ViewFilter ID
        [Parameter( Mandatory, ParameterSetName = 'Single' )]
        [int64]$ViewFilterID,
        # Object containing viewfilter id for batch processing.
        [Parameter( Mandatory, ParameterSetName = 'Batch')]
        [Object]$ViewFilter
    )
    Invoke-HaloPreFlightCheck
    try {
        if ($ViewFilter) {
            $ViewFilterID = $ViewFilter.Id
        }
        $ObjectToDelete = Get-HaloViewFilter -ViewFilterID $ViewFilterID
        if ($ObjectToDelete) {
            if ($PSCmdlet.ShouldProcess("ViewFilter '$($ObjectToDelete.id)'", 'Delete')) {
                $Resource = "api/viewfilter/$($ViewFilterID)"
                $ViewFilterResults = New-HaloDELETERequest -Resource $Resource
                Return $ViewFilterResults
            }
        } else {
            Throw 'ViewFilter was not found in Halo to delete.'
        }
    } catch {
        New-HaloError -ErrorRecord $_
    }
}