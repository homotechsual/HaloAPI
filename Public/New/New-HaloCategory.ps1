Function New-HaloCategory {
    <#
        .SYNOPSIS
            Creates a Category via the Halo API.
        .DESCRIPTION
            Function to send a Category creation request to the Halo API
        .OUTPUTS
            Outputs an object containing the response from the web request.
    #>
    [CmdletBinding( SupportsShouldProcess = $True )]
    [OutputType([Object])]
    Param (
        # Object containing properties and values used to create a new knowledgebase article.
        [Parameter( Mandatory = $True )]
        [Object]$Category
    )
    Invoke-HaloPreFlightCheck
    try {
        if ($PSCmdlet.ShouldProcess("Category '$($Category.name)'", 'Create')) {
            New-HaloPOSTRequest -Object $Category -Endpoint 'Category'
        }
    } catch {
        New-HaloError -ErrorRecord $_
    }
}