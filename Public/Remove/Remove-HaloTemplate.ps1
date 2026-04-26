function Remove-HaloTemplate {
    <#
        .SYNOPSIS
           Removes a template from the Halo API.
        .DESCRIPTION
            Deletes a specific template from Halo.
        .OUTPUTS
            A powershell object containing the response.
    #>
    [cmdletbinding( SupportsShouldProcess = $True, ConfirmImpact = 'High' )]
    [OutputType([Object])]
    Param(
        # The Template ID
        [Parameter( Mandatory = $True )]
        [Alias('Template')]
        [int64]$TemplateID
    )
    Invoke-HaloPreFlightCheck
    try {
        $ObjectToDelete = Get-HaloTemplate -TemplateID $TemplateID
        if ($ObjectToDelete) {
            if ($PSCmdlet.ShouldProcess(('Template ''{0}''' -f $ObjectToDelete.name), 'Delete')) {
                $Resource = ('api/template/{0}' -f $TemplateID)
                $TemplateResults = New-HaloDELETERequest -Resource $Resource
                Return $TemplateResults
            }
        } else {
            Throw 'Template was not found in Halo to delete.'
        }
    } catch {
        New-HaloError -ErrorRecord $_
    }
}
