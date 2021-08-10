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
        [ValidateSet(
            "all",
            "admin",
            "read:tickets",
            "edit:tickets",
            "read:calendar",
            "edit:calendar",
            "read:customers",
            "edit:customers",
            "read:contracts",
            "edit:contracts",
            "read:suppliers",
            "edit:suppliers",
            "read:items",
            "edit:items",
            "read:projects",
            "edit:projects",
            "read:sales",
            "edit:sales",
            "read:quotes",
            "edit:quotes",
            "read:sos",
            "edit:sos",
            "read:pos",
            "edit:pos",
            "read:invoices",
            "edit:invoices",
            "read:reporting",
            "edit:reporting",
            "read:timesheets",
            "edit:timesheets",
            "read:software",
            "edit:software",
            "read:kb",
            "edit:kb",
            "read:assets",
            "edit:assets",
            "access:chat",
            "access:adpasswordreset"
        )]
        [String[]]$Scopes = "all",
        # The tenant name required for hosted Halo instances.
        [Parameter(
            ParameterSetName = 'Client Credentials'
        )]
        [String]$Tenant
    )
    # Convert scopes to space separated string if it's an array.
    if ($Scopes -is [system.array]) {
        $AuthScopes = $Scopes -Join " "
    } else {
        $AuthScopes = $Scopes
    }
    # Build a script-scoped variable to hold the connection information.
    $ConnectionInformation = @{
        URL = $URL
        ClientID = $ClientID
        ClientSecret = $ClientSecret
        AuthScopes = $AuthScopes
        Tenant = $Tenant
    }
    Set-Variable -Name "HAPIConnectionInformation" -Value $ConnectionInformation -Visibility Private -Scope Script -Force
    Write-Debug "Connection information set to: $($Script:HAPIConnectionInformation | Out-String)"
    # Halo authorisation request body.
    $AuthReqBody = @{
        grant_type = "client_credentials"
        client_id = $Script:HAPIConnectionInformation.ClientID
        client_secret = $Script:HAPIConnectionInformation.ClientSecret
        scope = $Script:HAPIConnectionInformation.AuthScopes
    }
    # Build the authentication URL.
    if ($Tenant) {
        $AuthURL = "$($URL)auth/token?tenant=$($Tenant)"
    } else {
        $AuthURL = "$($URL)auth/token"
    }
    # Build the WebRequest parameters.
    $WebRequestParams = @{
        Uri = $AuthURL
        Method = "POST"
        Body = $AuthReqBody
        ContentType = "application/x-www-form-urlencoded" 
    }
    try {
        $AuthReponse = Invoke-WebRequest @WebRequestParams
        $TokenPayload = ConvertFrom-Json -InputObject $AuthReponse.Content
        # Build a script-scoped variable to hold the authentication information.
        $AuthToken = @{
            Type = $TokenPayload.token_type
            Access = $TokenPayload.access_token
            Expires = Get-TokenExpiry -ExpiresIn $TokenPayload.expires_in
            Refresh = $TokenPayload.refresh_token
            Id = $TokenPayload.id_token
        }
        Set-Variable -Name "HAPIAuthToken" -Value $AuthToken -Visibility Private -Scope Script -Force
        Write-Verbose "Got authentication token."
        Write-Debug "Authentication token set to: $($Script:HAPIAuthToken | Out-String -Width 2048)"
    } catch {
        $ExceptionResponse = $_.Exception.Response
        Write-Error "The Halo API request `($($ExceptionResponse.RequestMessage.Method) $($ExceptionResponse.RequestMessage.RequestUri)`) responded with $($ExceptionResponse.StatusCode.Value__): $($ExceptionResponse.ReasonPhrase). You'll see more detail if using '-Verbose'"
        Write-Verbose $_
    }
}