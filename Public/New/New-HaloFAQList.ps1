Function New-HaloFAQList {
    <#
        .SYNOPSIS
            Creates a FAQ List article via the Halo API.
        .DESCRIPTION
            Function to send a FAQ list creation request to the Halo API
        .OUTPUTS
            Outputs an object containing the response from the web request.
    #>
    [CmdletBinding( SupportsShouldProcess = $True )]
    [OutputType([Object])]
    Param (
        # Object containing properties and values used to create a new knowledgebase article.
        [Parameter( Mandatory = $True )]
        [Object]$FAQList
    )
    Invoke-HaloPreFlightCheck
    try {
        if ($PSCmdlet.ShouldProcess("FAQ List '$($FAQList.name)'", 'Create')) {
            New-HaloPOSTRequest -Object $FAQList -Endpoint 'FAQLists'
        }
    } catch {
        New-HaloError -ErrorRecord $_
    }
}