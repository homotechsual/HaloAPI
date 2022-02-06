using module ..\Classes\HaloLookup.psm1
using module ..\Classes\Completers\HaloAuthScopesCompleter.psm1
using module ..\Classes\Validators\HaloAuthScopesValidator.psm1
#Requires -Version 7
function Connect-HaloAPI {
    <#
        .SYNOPSIS
            Creates a new connection to a Halo instance.
        .DESCRIPTION
            Creates a new connection to a Halo instance and stores this in a PowerShell Session.
        .EXAMPLE
            PS C:\> Connect-HaloAPI -URL "https://example.halopsa.com" -ClientId "c9534241-dde9-4d04-9d45-32b1fbff22ed" -ClientSecret "14c0c9af-2db1-48ab-b29c-51975df4afa2-739e4ef2-9aad-4fe9-b486-794feca48ea8" -Scopes "all" -Tenant "demo"
            This logs into Halo using the Client Credentials authorisation flow.
        .OUTPUTS
            Sets two script-scoped variables to hold connection and authentication information.
    #>
    [CmdletBinding(
        DefaultParameterSetName = 'Client Credentials'
    )]
    [OutputType([System.Void])]
    Param (
        # The URL of the Halo instance to connect to.
        [Parameter(
            ParameterSetName = 'Client Credentials',
            Mandatory = $True
        )]
        [URI]$URL,
        # The Client ID for the application configured in Halo.
        [Parameter(
            ParameterSetName = 'Client Credentials',
            Mandatory = $True
        )]
        [String]$ClientID,
        # The Client Secret for the application configured in Halo.
        [Parameter(
            ParameterSetName = 'Client Credentials',
            Mandatory = $True
        )]
        [String]$ClientSecret,
        # The API scopes to request, if this isn't passed the scope is assumed to be "all". Pass a string or array of strings. Limited by the scopes granted to the application in Halo.
        [Parameter(
            ParameterSetName = 'Client Credentials'
        )]
        [ArgumentCompleter([HaloAuthScopesCompleter])]
        [ValidateSet([HaloAuthScopesValidator])]
        [String[]]$Scopes = 'all',
        # The tenant name required for hosted Halo instances.
        [Parameter(
            ParameterSetName = 'Client Credentials'
        )]
        [String]$Tenant
    )
    # Convert scopes to space separated string if it's an array.
    if ($Scopes -is [system.array]) {
        $AuthScopes = $Scopes -Join ' '
    } else {
        $AuthScopes = $Scopes
    }
    # Build the authentication and base URLs.
    $AuthInfoURIBuilder = [System.UriBuilder]::New($URL)
    Write-Verbose "Looking up auth endpoint using the 'api/authinfo' endpoint."
    $AuthInfoURIBuilder.Path = 'api/authinfo'
    $AuthInfoResponse = Invoke-WebRequest -Uri $AuthInfoURIBuilder.ToString() -Method 'GET'
    if ($AuthInfoResponse.content) {
        $AuthInfo = $AuthInfoResponse.content | ConvertFrom-Json
        Write-Debug "Auth info response: $AuthInfo"
        $AuthURIBuilder = [System.UriBuilder]::New($AuthInfo.auth_url)
        Write-Verbose "Auth info found, using the '$($AuthInfo.auth_url)' endpoint."
        if ($AuthURIBuilder.Path) {
            $AuthURIBuilder.Path = $AuthURIBuilder.Path.TrimEnd('/') + '/token'
        } else {
            $AuthURIBuilder.Path = 'token'
        }
        
        if ($Tenant) {
            $AuthURIBuilder.Query = "tenant=$($Tenant)"
        } elseif ($AuthInfo.tenant_id) {
            $AuthURIBuilder.Query = "tenant=$($AuthInfo.tenant_id)"
        }
    } else {
        $AuthURIBuilder = [System.UriBuilder]::New($URL)
        Write-Warning 'Could not retrieve authentication URL from Halo falling back to default.'
        if ($Tenant) {
            $AuthURIBuilder.Path = 'auth/token'
            $AuthURIBuilder.Query = "tenant=$($Tenant)"
        } else {
            $AuthURIBuilder.Path = 'auth/token'
        }
    }
    $AuthenticationURI = $AuthURIBuilder.ToString()
    Write-Verbose "Using authentication URL: $($AuthenticationURI)"
    # Make sure URL is a base URI.
    $BaseURIBuilder = [System.UriBuilder]::New($URL)
    if ($BaseURIBuilder.Path) {
        $BaseURIBuilder.Path = $null
        $BaseURIBuilder.Query = $null
        $BaseURI = $BaseURIBuilder.ToString()
    }
    # Build a script-scoped variable to hold the connection information.
    $ConnectionInformation = @{
        URL = $BaseURI
        ClientID = $ClientID
        ClientSecret = $ClientSecret
        AuthScopes = $AuthScopes
        Tenant = $Tenant
    }
    Set-Variable -Name 'HAPIConnectionInformation' -Value $ConnectionInformation -Visibility Private -Scope Script -Force
    Write-Debug "Connection information set to: $($Script:HAPIConnectionInformation | Out-String)"
    # Halo authorisation request body.
    $AuthReqBody = @{
        grant_type = 'client_credentials'
        client_id = $Script:HAPIConnectionInformation.ClientID
        client_secret = $Script:HAPIConnectionInformation.ClientSecret
        scope = $Script:HAPIConnectionInformation.AuthScopes
    }
    # Build the WebRequest parameters.
    $WebRequestParams = @{
        Uri = $AuthenticationURI
        Method = 'POST'
        Body = $AuthReqBody
        ContentType = 'application/x-www-form-urlencoded'
    }
    try {
        $AuthReponse = Invoke-WebRequest @WebRequestParams
        $TokenPayload = ConvertFrom-Json -InputObject $AuthReponse.Content
        Write-Debug "Raw Token Payload: $($TokenPayload | Out-String)"
        # Build a script-scoped variable to hold the authentication information.
        $AuthToken = @{
            Type = $TokenPayload.token_type
            Access = $TokenPayload.access_token
            Expires = Get-TokenExpiry -ExpiresIn $TokenPayload.expires_in
            Refresh = $TokenPayload.refresh_token
            Id = $TokenPayload.id_token
        }
        Set-Variable -Name 'HAPIAuthToken' -Value $AuthToken -Visibility Private -Scope Script -Force
        Write-Verbose 'Got authentication token.'
        Write-Debug "Authentication token set to: $($Script:HAPIAuthToken | Out-String -Width 2048)"
        Write-Debug 'Initialising the Halo Lookup class cache.'
        $LookupTypes = Get-HaloLookup -LookupID 11
        if ($LookupTypes) {
            [HaloLookup]::LookupTypes = $LookupTypes
        } else {
            Write-Error 'Failed to retrieve Halo lookup types.'
        }
        Write-Success "Connected to the Halo API with tenant URL $($Script:HAPIConnectionInformation.URL)"
    } catch {
        New-HaloError $_ -HasResponse
    }
}