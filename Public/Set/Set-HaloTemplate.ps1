Function Set-HaloTemplate {
    <#
        .SYNOPSIS
            Updates one or more templates via the Halo API.
        .DESCRIPTION
            Function to send a template update request to the Halo API
        .OUTPUTS
            Outputs an object containing the response from the web request.
    #>
    [CmdletBinding( SupportsShouldProcess = $True )]
    [OutputType([Object[]])]
    Param (
        # Object or array of objects containing properties and values used to update one or more existing templates.
        [Parameter( Mandatory = $True, ValueFromPipeline )]
        [Object[]]$Template,
        # Skip validation checks.
        [Parameter()]
        [Switch]$SkipValidation
    )
    Invoke-HaloPreFlightCheck
    try {
        $ObjectToUpdate = $Template | ForEach-Object {
            if ($null -eq $_.id) {
                throw 'Template ID is required.'
            }
            $HaloTemplateParams = @{
                TemplateId = $_.id
            }
            if (-not $SkipValidation) {
                $TemplateExists = Get-HaloTemplate @HaloTemplateParams
                if ($TemplateExists) {
                    Return $True
                } else {
                    Return $False
                }
            } else {
                Write-Verbose 'Skipping validation checks.'
                Return $True
            }
        }
        if ($False -notin $ObjectToUpdate) {
            if ($PSCmdlet.ShouldProcess($Template -is [Array] ? 'Templates' : 'Template', 'Update')) {
                $Results = New-HaloPOSTRequest -Object $Template -Endpoint 'template'
                Return $Results
            }
        } else {
            Throw 'One or more templates was not found in Halo to update.'
        }
    } catch {
        New-HaloError -ErrorRecord $_
    }
}
