function Remove-HaloOutcome {
    <#
        .SYNOPSIS
           Removes a Outcome from the Halo API.
        .DESCRIPTION
            Deletes a specific Outcome from Halo.
        .OUTPUTS
            A powershell object containing the response.
    #>
    [cmdletbinding( SupportsShouldProcess = $True, ConfirmImpact = 'High' )]
    [OutputType([Object])]
    Param(
        # The Outcome ID
        [Parameter( Mandatory = $True )]
        [Alias('Outcome')]
        [int64]$OutcomeID
    )
    Invoke-HaloPreFlightCheck
    try {
        $ObjectToDelete = Get-HaloOutcome -OutcomeID $OutcomeID
        if ($ObjectToDelete) {
            if ($PSCmdlet.ShouldProcess("Outcome '$($ObjectToDelete.name)')'", 'Delete')) {
                $Resource = "api/Outcome/$($OutcomeID)"
                $OutcomeResults = New-HaloDELETERequest -Resource $Resource
                Return $OutcomeResults
            }
        } else {
            Throw 'Outcome was not found in Halo to delete.'
        }
    } catch {
        New-HaloError -ErrorRecord $_
    }
}