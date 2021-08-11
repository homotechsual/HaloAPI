#Requires -Version 7
function Get-HaloTemplate {
    <#
        .SYNOPSIS
            Gets a template object for the Halo API.
        .DESCRIPTION
            Provides an example object for use in provisioning items in the Halo API
        .OUTPUTS
            A powershell object containing the response.
    #>
    [CmdletBinding( DefaultParameterSetName = "Multi" )]
    [OutputType([PSCustomObject])]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', '', Justification = 'Uses dynamic parameter parsing.')]
    Param(
        # Type of object to get template for
        [Parameter( Mandatory = $True )]
        [ValidateSet(
            "Action",
            "Agent",
            "Appointment",
            "Article",
            "Asset",
            "Attachment",
            "Client",
            "Invoice",
            "Item",
            "KBArticle",
            "Opportunity",
            "Project",
            "Quote",
            "Report",
            "Site",
            "Status",
            "Supplier",
            "Team",
            "Ticket",
            "TicketType",
            "User"
        )]
        [String]$Type,
        # Return with null values
        [switch]$NullVariables
    )
    # Handle types with aliases/multiple names.
    if ($Type -eq "Article") {
        $Type = "KBArticle"
    }
    # Fetch the object from a template json file in the data directory
    $TemplateObject = Get-Content "$PSScriptRoot/../Data/$Type.json" -Raw | ConvertFrom-Json -Depth 100
    # If null variables were requested null them all
    if ($NullVariables) {
        $ReturnObject = Get-HaloNullObject -NullObject $TemplateObject
    } else {
        $ReturnObject = $TemplateObject
    }

    return $ReturnObject
}