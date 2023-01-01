#Requires -Version 7
function Get-HaloAzureADConnection {
    <#
        .SYNOPSIS
            Gets Azure AD Connection information from the Halo API.
        .DESCRIPTION
            Retrieves Azure AD Connection from the Halo API - supports a variety of filtering parameters.
        .OUTPUTS
            A powershell object containing the response.
    #>
    [CmdletBinding( DefaultParameterSetName = 'Multi' )]
    [OutputType([Object])]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', '', Justification = 'Uses dynamic parameter parsing.')]
    Param(
        # Lookup Item ID
        [Parameter( ParameterSetName = 'Single', Mandatory = $True )]
        [int64]$AzureConnectionID,
        # Type
        [Parameter( ParameterSetName = 'Single' )]
        [Parameter( ParameterSetName = 'Multi')]
        [string]$Type,
        # Show All
        [Parameter( ParameterSetName = 'Multi')]
        [string]$ShowAll,
        # Include Details
        [Parameter( ParameterSetName = 'Single' )]
        [switch]$IncludeDetails,
        # Include Tenants
        [Parameter( ParameterSetName = 'Single' )]
        [switch]$IncludeTenants
    )
    Invoke-HaloPreFlightCheck
    $CommandName = $MyInvocation.MyCommand.Name
    $Parameters = (Get-Command -Name $CommandName).Parameters
    # Workaround to prevent the query string processor from adding a 'AzureConnectionID=' parameter by removing it from the set parameters.
    if ($AzureConnectionID) {
        $Parameters.Remove('AzureConnectionID') | Out-Null
    }
    $QSCollection = New-HaloQuery -CommandName $CommandName -Parameters $Parameters
    try {
        if ($AzureConnectionID) {
            Write-Verbose "Running in single-field mode because 'AzureConnectionID' was provided."
            $Resource = "api/azureadconnection/$($AzureConnectionID)"
        } else {
            Write-Verbose 'Running in multi-field mode.'
            $Resource = 'api/azureadconnection'
        }
        $RequestParams = @{
            Method = 'GET'
            Resource = $Resource
            AutoPaginateOff = $True
            QSCollection = $QSCollection
            ResourceType = 'azureadconnection'
        }
        $AzureADConnections = New-HaloGETRequest @RequestParams
        Return $AzureADConnections
    } catch {
        New-HaloError -ErrorRecord $_
    }
}