function Remove-HaloCustomField {
    <#
        .SYNOPSIS
           Removes a Custom Field from the Halo API.
        .DESCRIPTION
            Deletes a specific Custom Field from Halo.
        .OUTPUTS
            A powershell object containing the response.
    #>
    [cmdletbinding( SupportsShouldProcess = $True, ConfirmImpact = 'High' )]
    [OutputType([Object])]
    Param(
        # The Custom Field ID
        [Parameter( Mandatory = $True )]
        [int64]$CustomFieldID
    )
    Invoke-HaloPreFlightCheck
    try {
        $ObjectToDelete = Get-HaloCustomField -CustomFieldID $CustomFieldID
        if ($ObjectToDelete) {
            if ($PSCmdlet.ShouldProcess("Custom Field '$($ObjectToDelete.name)')'", 'Delete')) {
                $Resource = "api/FieldInfo/$($CustomFieldID)"
                $CustomFieldResults = New-HaloDELETERequest -Resource $Resource
                Return $CustomFieldResults
            }
        } else {
            Throw 'Custom Field was not found in Halo to delete.'
        }
    } catch {
        New-HaloError -ErrorRecord $_
    }
}