function Remove-HaloCategory {
    <#
        .SYNOPSIS
           Removes an Category from the Halo API.
        .DESCRIPTION
            Deletes a specific Category from Halo.
        .OUTPUTS
            A powershell object containing the response.
    #>
    [cmdletbinding( SupportsShouldProcess = $True, ConfirmImpact = 'High' )]
    [OutputType([Object])]
    Param(
        # The Category ID
        [Parameter( Mandatory = $True )]
        [alias('category_id')]
        [int64]$CategoryID
    )
    Invoke-HaloPreFlightCheck
    try {
        $ObjectToDelete = Get-HaloCategory -CategoryID $CategoryID
        if ($ObjectToDelete) {
            if ($PSCmdlet.ShouldProcess("Category '$($ObjectToDelete.value)'", 'Delete')) {
                $Resource = "api/Category/$($CategoryID)"
                $ActionResults = New-HaloDELETERequest -Resource $Resource
                Return $ActionResults
            }
        } else {
            Throw 'Category was not found in Halo to delete.'
        }
    } catch {
        New-HaloError -ErrorRecord $_
    }
}