Function Remove-HaloArea {
    <#
    .SYNOPSIS
        Removes an Area from the API
    .DESCRIPTION
        Removes a specific area or areas from Halo using the API.
    .EXAMPLE
        PS> Remove-HaloArea -areaid 1
        Removes area with an ID of 1
    .NOTES
        General notes
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
    [Alias('Remove-HaloAreas')]
    [OutputType([Object])]
    Param (
        # The ID of the area to remove
        [Parameter(Mandatory = $false, ValueFromPipeline = $True, Position = 0, ValueFromPipelineByPropertyName = $True, ValueFromRemainingArguments = $true)]
        [Alias('area_id')]
        [int64]$areaid
    )
    Invoke-HaloPreFlightCheck
    try {
        $ObjectToDelete = Get-HaloArea -areaid $areaid
        if ($null -ne $ObjectToDelete) {
            If ($PSCmdlet.ShouldProcess("Area '$($ObjectToDelete.name)'", 'Delete')) {
                $resource = "api/ticketArea/$($areaid)"
                $actionResults = New-HaloDELETERequest -Resource $resource
                return $actionResults
            }
        } else {
            Throw 'Area was not found in Halo to delete.'
        }
    } catch {
        New-HaloError -ErrorRecord $_
        return
    }
}