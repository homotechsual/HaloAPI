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
        .EXAMPLE
            PS C:\> Connect-HaloAPI -URL "https://example.halopsa.com" -ClientId "c9534241-dde9-4d04-9d45-32b1fbff22ed" -Tenant "demo" -Interactive
            This opens a browser to sign in to Halo with your own agent account using the Authorisation Code flow with PKCE. No client secret is needed: create the API application in Halo with the "Authorisation Code (Native Application)" authentication method and add "http://localhost:8400/" as a redirect URI. Requests then run with the signed-in agent's permissions and the token is refreshed automatically.
    #>
    [CmdletBinding(
        DefaultParameterSetName = 'Client Credentials'
    )]
    [OutputType([System.Void])]
    Param (
        # The URL of the Halo instance to connect to. Not required if UseKeyVault is set to $true.
        [Parameter(
            ParameterSetName = 'Client Credentials',
            Mandatory = $False
        )]
        [Parameter(
            ParameterSetName = 'Authorisation Code',
            Mandatory = $True
        )]
        [URI]$URL,
        # The Client ID for the application configured in Halo. Not required if UseKeyVault is set to $true.
        [Parameter(
            ParameterSetName = 'Client Credentials',
            Mandatory = $False
        )]
        [Parameter(
            ParameterSetName = 'Authorisation Code',
            Mandatory = $True
        )]
        [String]$ClientID,
        # The Client Secret for the application configured in Halo. Not required if UseKeyVault is set to $true.
        [Parameter(
            ParameterSetName = 'Client Credentials',
            Mandatory = $False
        )]
        [String]$ClientSecret,
        # The API scopes to request, if this isn't passed the scope is assumed to be "all". Pass a string or array of strings. Limited by the scopes granted to the application in Halo.
        [Parameter(
            ParameterSetName = 'Client Credentials'
        )]
        [Parameter(
            ParameterSetName = 'Authorisation Code'
        )]
        [String[]]$Scopes = 'all',
        # The tenant name required for hosted Halo instances.
        [Parameter(
            ParameterSetName = 'Client Credentials'
        )]
        [Parameter(
            ParameterSetName = 'Authorisation Code'
        )]
        [String]$Tenant,
        # Sign in through the browser with your own Halo agent account (Authorisation Code flow with PKCE) instead of using a client secret.
        [Parameter(
            ParameterSetName = 'Authorisation Code',
            Mandatory = $True
        )]
        [Switch]$Interactive,
        # The redirect URI configured on the Halo API application. A temporary local listener is started on this address to receive the sign-in response.
        [Parameter(
            ParameterSetName = 'Authorisation Code'
        )]
        [URI]$RedirectURI = 'http://localhost:8400/',
        # How long to wait, in seconds, for the browser sign-in to complete.
        [Parameter(
            ParameterSetName = 'Authorisation Code'
        )]
        [Int]$LoginTimeout = 300,
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
        # When set to $true, uses a Managed Identity to connect to Azure Key Vault instead of interactive login.
        [Parameter(
            ParameterSetName = 'Client Credentials',
            Mandatory = $False
        )]
        [Switch]$UseManagedIdentity,
        # The maximum number of times to retry requests before giving up.
        [Parameter(
            ParameterSetName = 'Client Credentials',
            Mandatory = $False
        )]
        [Parameter(
            ParameterSetName = 'Authorisation Code'
        )]
        [Int]$MaxRetries = 10,
        # Don't return a boolean to confirm the connection status.
        [Parameter(
            ParameterSetName = 'Client Credentials',
            Mandatory = $False
        )]
        [Parameter(
            ParameterSetName = 'Authorisation Code'
        )]
        [Switch]$NoConfirm
    )
    $UseAuthorisationCode = $PSCmdlet.ParameterSetName -eq 'Authorisation Code'
    if ($UseAuthorisationCode -and -not $RedirectURI.AbsolutePath.EndsWith('/')) {
        throw 'RedirectURI must have a trailing slash so the Halo redirect URI matches the listener prefix.'
    }
    # Validate that required parameters are provided when not using KeyVault
    if (-not $UseAuthorisationCode -and -not $UseKeyVault -and -not $SaveToKeyVault) {
        if ([string]::IsNullOrWhiteSpace($URL)) {
            throw 'URL parameter is required when UseKeyVault is not specified.'
        }
        if ([string]::IsNullOrWhiteSpace($ClientID)) {
            throw 'ClientID parameter is required when UseKeyVault is not specified.'
        }
        if ([string]::IsNullOrWhiteSpace($ClientSecret)) {
            throw 'ClientSecret parameter is required when UseKeyVault is not specified.'
        }
    }
    if ($UseKeyVault) {
        # If the Identity parameter is specified, use it to connect.
        # Otherwise, fall back to interactive login.
        if ($UseManagedIdentity) {
            Connect-AzAccount -Identity
        } else {
            Connect-AzAccount
        }
        $URL = Get-AzKeyVaultSecret -VaultName $VaultName -Name ('{0}-URL' -f $SecretName) -AsPlainText
        $ClientID = Get-AzKeyVaultSecret -VaultName $VaultName -Name ('{0}-ClientID' -f $SecretName) -AsPlainText
        $ClientSecret = Get-AzKeyVaultSecret -VaultName $VaultName -Name ('{0}-ClientSecret' -f $SecretName) -AsPlainText
    } elseif ($SaveToKeyVault) {
        # Save the URL, ClientID, and ClientSecret to the Azure Key Vault.
        if ($UseManagedIdentity) {
            Connect-AzAccount -Identity
        } else {
            Connect-AzAccount
        }
        $URL_Secret = ConvertTo-SecureString -String $URL -AsPlainText -Force
        Set-AzKeyVaultSecret -VaultName $VaultName -Name ('{0}-URL' -f $SecretName) -SecretValue $URL_Secret

        $ClientID_Secret = ConvertTo-SecureString -String $ClientID -AsPlainText -Force
        Set-AzKeyVaultSecret -VaultName $VaultName -Name ('{0}-ClientID' -f $SecretName) -SecretValue $ClientID_Secret

        $ClientSecret_Secret = ConvertTo-SecureString -String $ClientSecret -AsPlainText -Force
        Set-AzKeyVaultSecret -VaultName $VaultName -Name ('{0}-ClientSecret' -f $SecretName) -SecretValue $ClientSecret_Secret
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
    $AuthInfoRetries = 0
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
    } while ((-not $AuthInfoResponse) -and ($AuthInfoRetries -lt 10))
    if ((-not $AuthInfoResponse) -and ($AuthInfoRetries -gt 1)) {
        New-HaloError -ModuleMessage ('Retried auth info request {0} times, request unsuccessful.' -f $AuthInfoRetries)
    }
    if ($AuthInfoResponse.content) {
        $AuthInfo = $AuthInfoResponse.content | ConvertFrom-Json
        Write-Debug ('Auth info response received with properties: {0}' -f (@($AuthInfo.PSObject.Properties.Name) -join ', '))
        $AuthURIBuilder = [System.UriBuilder]::New($AuthInfo.auth_url)
        Write-Verbose 'Auth info found.'
        if ($AuthURIBuilder.Path) {
            $AuthURIBuilder.Path = $AuthURIBuilder.Path.TrimEnd('/') + '/token'
        } else {
            $AuthURIBuilder.Path = 'token'
        }
        
        if ($Tenant) {
            $AuthURIBuilder.Query = ('tenant={0}' -f $Tenant)
        } elseif ($AuthInfo.tenant_id) {
            $AuthURIBuilder.Query = ('tenant={0}' -f $AuthInfo.tenant_id)
        }
    } else {
        $AuthURIBuilder = [System.UriBuilder]::New($URL)
        Write-Warning 'Could not retrieve authentication URL from Halo falling back to default.'
        if ($Tenant) {
            $AuthURIBuilder.Path = 'auth/token'
            $AuthURIBuilder.Query = ('tenant={0}' -f $Tenant)
        } else {
            $AuthURIBuilder.Path = 'auth/token'
        }
    }
    $AuthenticationURI = $AuthURIBuilder.ToString()
    $AuthenticationLogURI = [System.UriBuilder]::New($AuthenticationURI)
    $AuthenticationLogURI.UserName = $null
    $AuthenticationLogURI.Password = $null
    $AuthenticationLogURI.Query = $null
    $AuthenticationLogURI.Fragment = $null
    Write-Verbose ('Using authentication endpoint: {0}' -f $AuthenticationLogURI.Uri.GetLeftPart([System.UriPartial]::Authority))
    # The authorise endpoint sits alongside the token endpoint.
    $AuthoriseURIBuilder = [System.UriBuilder]::New($AuthenticationURI)
    $AuthoriseURIBuilder.Path = $AuthoriseURIBuilder.Path -replace 'token$', 'authorize'
    $AuthoriseURI = $AuthoriseURIBuilder.Uri.AbsoluteUri
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
        AuthFlow = $PSCmdlet.ParameterSetName
        AuthURI = $AuthenticationURI
    }
    if ($UseAuthorisationCode) {
        $ConnectionInformation.AuthoriseURI = $AuthoriseURI
        $ConnectionInformation.RedirectURI = $RedirectURI.AbsoluteUri
        $ConnectionInformation.LoginTimeout = $LoginTimeout
    }
    Set-Variable -Name 'HAPIConnectionInformation' -Value $ConnectionInformation -Visibility Private -Scope Script -Force
    Write-Debug ('Connection information set for authentication flow: {0}' -f $Script:HAPIConnectionInformation.AuthFlow)
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
    $AuthRetries = 0
    do {
        $AuthRetries++
        try {
            Set-Variable -Name 'HAPIAuthToken' -Value $null -Visibility Private -Scope Script -Force
            if ($UseAuthorisationCode) {
                $TokenPayload = Invoke-HaloAuthorisationCodeFlow -ConnectionInformation $Script:HAPIConnectionInformation
            } else {
                $AuthReponse = Invoke-WebRequest @WebRequestParams
                $TokenPayload = ConvertFrom-Json -InputObject $AuthReponse.Content
            }
            # Build a script-scoped variable to hold the authentication information.
            $AuthToken = ConvertTo-HaloAuthToken -TokenPayload $TokenPayload
            Set-Variable -Name 'HAPIAuthToken' -Value $AuthToken -Visibility Private -Scope Script -Force
            Write-Verbose 'Got authentication token.'
            Write-Debug ('Authentication token set; expiry: {0}' -f $Script:HAPIAuthToken.Expires)
            Write-Debug 'Initialising the Halo Lookup class cache.'
            $LookupTypes = Get-HaloLookup -LookupID 11
            if ($LookupTypes) {
                [HaloLookup]::LookupTypes = $LookupTypes
            } else {
                New-HaloError -ModuleMessage 'Could not retrieve lookup types from Halo.'
            }
            Write-Success ('Connected to the Halo API with tenant URL {0}' -f $Script:HAPIConnectionInformation.URL)
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
    if ((-not $Authenticated) -and ($AuthRetries -gt 1)) {
        New-HaloError -ModuleMessage ('Retried auth request {0} times, request unsuccessful.' -f $AuthRetries)
    }
    if (!$NoConfirm) {
        return $Authenticated
    }
}