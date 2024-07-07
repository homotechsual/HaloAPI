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
            PS C:\> Connect-HaloAPI -URL "https://example.halopsa.com" -ClientId "c9534241-dde9-4d04-9d45-32b1fbff22ed" -ClientSecret "14c0c9af-2db1-48ab-b29c-51975df4afa2-739e4ef2-9aad-4fe9-b486-794feca48ea8" -Scopes "all" -Tenant "demo" -VaultName "MyVault" -SaveToKeyVault $true
            This logs into Halo using the Client Credentials authorisation flow and saves the secrets to the specified Azure Key Vault for future use.
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
        [String[]]$Scopes = 'all',
        # The tenant name required for hosted Halo instances.
        [Parameter(
            ParameterSetName = 'Client Credentials'
        )]
        [String]$Tenant,
        # Hashtable containing additional parameters to be sent with each request.
        [Hashtable]$AdditionalHeaders,
        # If $true, retrieve parameters from Azure Key Vault. If $false, use parameters passed to function.
        [Parameter(
            ParameterSetName = 'Client Credentials'
        )]
        [bool]$UseKeyVault = $False,
        # The name of the secret in the Azure Key Vault.
        [Parameter(
            ParameterSetName = 'Client Credentials',
            Mandatory = $False
        )]
        [String]$SecretName,
        # The name of the Azure Key Vault.
        [Parameter(
            ParameterSetName = 'Client Credentials',
            Mandatory = $False
        )]
        [String]$VaultName,
        # If $true, save parameters to Azure Key Vault. If $false or not specified, do not save parameters.
        [Parameter(
            ParameterSetName = 'Client Credentials'
        )]
        [bool]$SaveToKeyVault = $False,
        # The object ID of the Managed Identity or Service Principal.
        [Parameter(
            ParameterSetName = 'Client Credentials',
            Mandatory = $False
        )]
        [String]$Identity,
        # The maximum number of times to retry requests before giving up.
        [Parameter(
            ParameterSetName = 'Client Credentials',
            Mandatory = $False
        )]
        [Int]$MaxRetries = 10,
        # Don't return a boolean to confirm the connection status.
        [Parameter(
            ParameterSetName = 'Client Credentials',
            Mandatory = $False
        )]
        [Switch]$NoConfirm
    )
    if ($UseKeyVault) {
        # If the Identity parameter is specified, use it to connect.
        # Otherwise, fall back to interactive login.
        if ($Identity) {
            Connect-AzAccount -Identity
        } else {
            Connect-AzAccount
        }
        $URL = (Get-AzKeyVaultSecret -VaultName $VaultName -Name "${SecretName}_URL").SecretValueText
        $ClientID = (Get-AzKeyVaultSecret -VaultName $VaultName -Name "${SecretName}_ClientID").SecretValueText
        $ClientSecret = (Get-AzKeyVaultSecret -VaultName $VaultName -Name "${SecretName}_ClientSecret").SecretValueText
    } elseif ($SaveToKeyVault) {
        # Save the URL, ClientID, and ClientSecret to the Azure Key Vault.
        if ($Identity) {
            Connect-AzAccount -Identity
        } else {
            Connect-AzAccount
        }
        $URL_Secret = ConvertTo-SecureString -String $URL -AsPlainText -Force
        Set-AzKeyVaultSecret -VaultName $VaultName -Name "${SecretName}_URL" -SecretValue $URL_Secret

        $ClientID_Secret = ConvertTo-SecureString -String $ClientID -AsPlainText -Force
        Set-AzKeyVaultSecret -VaultName $VaultName -Name "${SecretName}_ClientID" -SecretValue $ClientID_Secret

        $ClientSecret_Secret = ConvertTo-SecureString -String $ClientSecret -AsPlainText -Force
        Set-AzKeyVaultSecret -VaultName $VaultName -Name "${SecretName}_ClientSecret" -SecretValue $ClientSecret_Secret
    }

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
    $AuthInfoParams = @{
        Uri = $AuthInfoURIBuilder.ToString()
        Method = 'GET'
        Headers = $AdditionalHeaders
    }
    do {
        $AuthInfoRetries++
        try {
            $AuthInfoResponse = Invoke-WebRequest @AuthInfoParams
        } catch [Microsoft.PowerShell.Commands.HttpResponseException] {
            $AuthInfoResponse = $False
            if ($_.Exception.Response.StatusCode.value__ -eq 429) {
                Write-Warning 'The request was throttled, waiting for 5 seconds.'
                Start-Sleep -Seconds 5
                continue
            } else {
                throw $_
                break
            }
        } catch {
            New-HaloError -ErrorRecord $_ -HasResponse
        }
    } while ((-not $AuthInfoResponse) -and ($AuthRetries -lt 10))
    if ($AuthInfoRetries -gt 1) {
        New-HaloError -ModuleMessage ('Retried auth info request {0} times, request unsuccessful.' -f $Retries)
    }
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
        AdditionalHeaders = $AdditionalHeaders
        MaxRetries = $MaxRetries
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
        Headers = $AdditionalHeaders
    }
    do {
        $AuthRetries++
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
                New-HaloError -ModuleMessage 'Could not retrieve lookup types from Halo.'
            }
            Write-Success "Connected to the Halo API with tenant URL $($Script:HAPIConnectionInformation.URL)"
            $Authenticated = $True
        } catch [Microsoft.PowerShell.Commands.HttpResponseException] {
            $Authenticated = $False
            if ($_.Exception.Response.StatusCode.value__ -eq 429) {
                Write-Warning 'The request was throttled, waiting for 5 seconds.'
                Start-Sleep -Seconds 5
                continue
            } else {
                throw $_
                break
            }
        } catch {
            New-HaloError -ErrorRecord $_
        }
    } while ((-not $Authenticated) -and ($AuthRetries -lt 10))
    if (!$NoConfirm) {
        return $Authenticated
    }
    if ($AuthRetries -gt 1) {
        New-HaloError -ModuleMessage ('Retried auth request {0} times, request unsuccessful.' -f $Retries)
    }
}