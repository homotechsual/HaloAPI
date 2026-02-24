#Requires -Version 7
function Get-HaloAgentRoles {
    <#
        .SYNOPSIS
            Gets agent roles from the Halo API.
        .DESCRIPTION
            Retrieves agent roles from the Halo API - supports a variety of filtering parameters.
        .OUTPUTS
            A powershell object containing the response.
        .EXAMPLE
            PS C:\> Get-HaloAgentRoles
            Retrieves all agent roles from the Halo API.
        .EXAMPLE
            PS C:\> Get-HaloAgentRoles -RoleID "03cbebd0-3443-4b7b-8121-9a94ccfc49d1" -IncludeDetails
            Retrieves a specific agent role including detailed information.
    #>
    [CmdletBinding(DefaultParameterSetName = 'Multi')]
    [OutputType([Object])]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', '', Justification = 'Uses dynamic parameter parsing.')]
    Param(
        # Role ID - accepts a guid string
        [Parameter(ParameterSetName = 'Single', Mandatory = $True)]
        [string]$RoleID,
        
        # Include extra objects in the result for a single role
        [Parameter(ParameterSetName = 'Single')]
        [switch]$IncludeDetails,
        
        # Return the configuration information for a single role
        [Parameter(ParameterSetName = 'Single')]
        [switch]$IsConfig,
        
        # Include inactive roles in the response
        [Parameter(ParameterSetName = 'Multi')]
        [switch]$IncludeInactive,
        
        # Search for roles by name
        [Parameter(ParameterSetName = 'Multi')]
        [string]$Search,
        
        # Include API agent roles in the response
        [Parameter(ParameterSetName = 'Multi')]
        [switch]$IncludeAPIAgents,
        
        # Show all roles, including those that have been deleted
        [Parameter(ParameterSetName = 'Multi')]
        [switch]$ShowAll
    )
    
    Invoke-HaloPreFlightCheck
    $CommandName = $MyInvocation.MyCommand.Name
    $Parameters = (Get-Command -Name $CommandName).Parameters
    
    # Workaround to prevent the query string processor from adding a 'roleid=' parameter
    if ($RoleID) {
        $Parameters.Remove('RoleID') | Out-Null
    }
    
    $QSCollection = New-HaloQuery -CommandName $CommandName -Parameters $Parameters
    
    try {
        if ($RoleID) {
            Write-Verbose "Running in single-role mode because '-RoleID' was provided."
            $Resource = "api/Roles/$($RoleID)"
        } else {
            Write-Verbose 'Running in multi-role mode.'
            $Resource = 'api/Roles'
        }
        
        $RequestParams = @{
            Method = 'GET'
            Resource = $Resource
            AutoPaginateOff = $True
            QSCollection = $QSCollection
            ResourceType = 'roles'
        }
        
        $RoleResults = New-HaloGETRequest @RequestParams
        Return $RoleResults
    } catch {
        New-HaloError -ErrorRecord $_
    }
}