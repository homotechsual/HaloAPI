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
        [String]$Identity
    )
	

  if ($UseKeyVault) {
        # If the Identity parameter is specified, use it to connect.
        # Otherwise, fall back to interactive login.
        if ($Identity) {
            Connect-AzAccount -Identity
        } 
		else {
            Connect-AzAccount
        }
        $URL = (Get-AzKeyVaultSecret -VaultName $VaultName -Name "${SecretName}_URL").SecretValueText
        $ClientID = (Get-AzKeyVaultSecret -VaultName $VaultName -Name "${SecretName}_ClientID").SecretValueText
        $ClientSecret = (Get-AzKeyVaultSecret -VaultName $VaultName -Name "${SecretName}_ClientSecret").SecretValueText
    } elseif ($SaveToKeyVault) {
        # Save the URL, ClientID, and ClientSecret to the Azure Key Vault.
       if ($Identity) {
            Connect-AzAccount -Identity
        } 
		else {
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
                Write-Error 'Failed to retrieve Halo lookup types.'
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
    if ($AuthRetries -gt 1) {
        New-HaloError -ModuleMessage ('Retried auth request {0} times, request unsuccessful.' -f $Retries)
    }
}
# SIG # Begin signature block
# MIIrMAYJKoZIhvcNAQcCoIIrITCCKx0CAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCCPERVs3c7cE1JR
# LxUPY7YsZmYFTUImrqAa/mKf2sEScKCCJFUwggQyMIIDGqADAgECAgEBMA0GCSqG
# SIb3DQEBBQUAMHsxCzAJBgNVBAYTAkdCMRswGQYDVQQIDBJHcmVhdGVyIE1hbmNo
# ZXN0ZXIxEDAOBgNVBAcMB1NhbGZvcmQxGjAYBgNVBAoMEUNvbW9kbyBDQSBMaW1p
# dGVkMSEwHwYDVQQDDBhBQUEgQ2VydGlmaWNhdGUgU2VydmljZXMwHhcNMDQwMTAx
# MDAwMDAwWhcNMjgxMjMxMjM1OTU5WjB7MQswCQYDVQQGEwJHQjEbMBkGA1UECAwS
# R3JlYXRlciBNYW5jaGVzdGVyMRAwDgYDVQQHDAdTYWxmb3JkMRowGAYDVQQKDBFD
# b21vZG8gQ0EgTGltaXRlZDEhMB8GA1UEAwwYQUFBIENlcnRpZmljYXRlIFNlcnZp
# Y2VzMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAvkCd9G7h6naHHE1F
# RI6+RsiDBp3BKv4YH47kAvrzq11QihYxC5oG0MVwIs1JLVRjzLZuaEYLU+rLTCTA
# vHJO6vEVrvRUmhIKw3qyM2Di2olV8yJY897cz++DhqKMlE+faPKYkEaEJ8d2v+PM
# NSyLXgdkZYLASLCokflhn3YgUKiRx2a163hiA1bwihoT6jGjHqCZ/Tj29icyWG8H
# 9Wu4+xQrr7eqzNZjX3OM2gWZqDioyxd4NlGs6Z70eDqNzw/ZQuKYDKsvnw4B3u+f
# mUnxLd+sdE0bmLVHxeUp0fmQGMdinL6DxyZ7Poolx8DdneY1aBAgnY/Y3tLDhJwN
# XugvyQIDAQABo4HAMIG9MB0GA1UdDgQWBBSgEQojPpbxB+zirynvgqV/0DCktDAO
# BgNVHQ8BAf8EBAMCAQYwDwYDVR0TAQH/BAUwAwEB/zB7BgNVHR8EdDByMDigNqA0
# hjJodHRwOi8vY3JsLmNvbW9kb2NhLmNvbS9BQUFDZXJ0aWZpY2F0ZVNlcnZpY2Vz
# LmNybDA2oDSgMoYwaHR0cDovL2NybC5jb21vZG8ubmV0L0FBQUNlcnRpZmljYXRl
# U2VydmljZXMuY3JsMA0GCSqGSIb3DQEBBQUAA4IBAQAIVvwC8Jvo/6T61nvGRIDO
# T8TF9gBYzKa2vBRJaAR26ObuXewCD2DWjVAYTyZOAePmsKXuv7x0VEG//fwSuMdP
# WvSJYAV/YLcFSvP28cK/xLl0hrYtfWvM0vNG3S/G4GrDwzQDLH2W3VrCDqcKmcEF
# i6sML/NcOs9sN1UJh95TQGxY7/y2q2VuBPYb3DzgWhXGntnxWUgwIWUDbOzpIXPs
# mwOh4DetoBUYj/q6As6nLKkQEyzU5QgmqyKXYPiQXnTUoppTvfKpaOCibsLXbLGj
# D56/62jnVvKu8uMrODoJgbVrhde+Le0/GreyY+L1YiyC1GoAQVDxOYOflek2lphu
# MIIFbzCCBFegAwIBAgIQSPyTtGBVlI02p8mKidaUFjANBgkqhkiG9w0BAQwFADB7
# MQswCQYDVQQGEwJHQjEbMBkGA1UECAwSR3JlYXRlciBNYW5jaGVzdGVyMRAwDgYD
# VQQHDAdTYWxmb3JkMRowGAYDVQQKDBFDb21vZG8gQ0EgTGltaXRlZDEhMB8GA1UE
# AwwYQUFBIENlcnRpZmljYXRlIFNlcnZpY2VzMB4XDTIxMDUyNTAwMDAwMFoXDTI4
# MTIzMTIzNTk1OVowVjELMAkGA1UEBhMCR0IxGDAWBgNVBAoTD1NlY3RpZ28gTGlt
# aXRlZDEtMCsGA1UEAxMkU2VjdGlnbyBQdWJsaWMgQ29kZSBTaWduaW5nIFJvb3Qg
# UjQ2MIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAjeeUEiIEJHQu/xYj
# ApKKtq42haxH1CORKz7cfeIxoFFvrISR41KKteKW3tCHYySJiv/vEpM7fbu2ir29
# BX8nm2tl06UMabG8STma8W1uquSggyfamg0rUOlLW7O4ZDakfko9qXGrYbNzszwL
# DO/bM1flvjQ345cbXf0fEj2CA3bm+z9m0pQxafptszSswXp43JJQ8mTHqi0Eq8Nq
# 6uAvp6fcbtfo/9ohq0C/ue4NnsbZnpnvxt4fqQx2sycgoda6/YDnAdLv64IplXCN
# /7sVz/7RDzaiLk8ykHRGa0c1E3cFM09jLrgt4b9lpwRrGNhx+swI8m2JmRCxrds+
# LOSqGLDGBwF1Z95t6WNjHjZ/aYm+qkU+blpfj6Fby50whjDoA7NAxg0POM1nqFOI
# +rgwZfpvx+cdsYN0aT6sxGg7seZnM5q2COCABUhA7vaCZEao9XOwBpXybGWfv1Vb
# HJxXGsd4RnxwqpQbghesh+m2yQ6BHEDWFhcp/FycGCvqRfXvvdVnTyheBe6QTHrn
# xvTQ/PrNPjJGEyA2igTqt6oHRpwNkzoJZplYXCmjuQymMDg80EY2NXycuu7D1fkK
# dvp+BRtAypI16dV60bV/AK6pkKrFfwGcELEW/MxuGNxvYv6mUKe4e7idFT/+IAx1
# yCJaE5UZkADpGtXChvHjjuxf9OUCAwEAAaOCARIwggEOMB8GA1UdIwQYMBaAFKAR
# CiM+lvEH7OKvKe+CpX/QMKS0MB0GA1UdDgQWBBQy65Ka/zWWSC8oQEJwIDaRXBeF
# 5jAOBgNVHQ8BAf8EBAMCAYYwDwYDVR0TAQH/BAUwAwEB/zATBgNVHSUEDDAKBggr
# BgEFBQcDAzAbBgNVHSAEFDASMAYGBFUdIAAwCAYGZ4EMAQQBMEMGA1UdHwQ8MDow
# OKA2oDSGMmh0dHA6Ly9jcmwuY29tb2RvY2EuY29tL0FBQUNlcnRpZmljYXRlU2Vy
# dmljZXMuY3JsMDQGCCsGAQUFBwEBBCgwJjAkBggrBgEFBQcwAYYYaHR0cDovL29j
# c3AuY29tb2RvY2EuY29tMA0GCSqGSIb3DQEBDAUAA4IBAQASv6Hvi3SamES4aUa1
# qyQKDKSKZ7g6gb9Fin1SB6iNH04hhTmja14tIIa/ELiueTtTzbT72ES+BtlcY2fU
# QBaHRIZyKtYyFfUSg8L54V0RQGf2QidyxSPiAjgaTCDi2wH3zUZPJqJ8ZsBRNraJ
# AlTH/Fj7bADu/pimLpWhDFMpH2/YGaZPnvesCepdgsaLr4CnvYFIUoQx2jLsFeSm
# TD1sOXPUC4U5IOCFGmjhp0g4qdE2JXfBjRkWxYhMZn0vY86Y6GnfrDyoXZ3JHFuu
# 2PMvdM+4fvbXg50RlmKarkUT2n/cR/vfw1Kf5gZV6Z2M8jpiUbzsJA8p1FiAhORF
# e1rYMIIGGjCCBAKgAwIBAgIQYh1tDFIBnjuQeRUgiSEcCjANBgkqhkiG9w0BAQwF
# ADBWMQswCQYDVQQGEwJHQjEYMBYGA1UEChMPU2VjdGlnbyBMaW1pdGVkMS0wKwYD
# VQQDEyRTZWN0aWdvIFB1YmxpYyBDb2RlIFNpZ25pbmcgUm9vdCBSNDYwHhcNMjEw
# MzIyMDAwMDAwWhcNMzYwMzIxMjM1OTU5WjBUMQswCQYDVQQGEwJHQjEYMBYGA1UE
# ChMPU2VjdGlnbyBMaW1pdGVkMSswKQYDVQQDEyJTZWN0aWdvIFB1YmxpYyBDb2Rl
# IFNpZ25pbmcgQ0EgUjM2MIIBojANBgkqhkiG9w0BAQEFAAOCAY8AMIIBigKCAYEA
# myudU/o1P45gBkNqwM/1f/bIU1MYyM7TbH78WAeVF3llMwsRHgBGRmxDeEDIArCS
# 2VCoVk4Y/8j6stIkmYV5Gej4NgNjVQ4BYoDjGMwdjioXan1hlaGFt4Wk9vT0k2oW
# JMJjL9G//N523hAm4jF4UjrW2pvv9+hdPX8tbbAfI3v0VdJiJPFy/7XwiunD7mBx
# NtecM6ytIdUlh08T2z7mJEXZD9OWcJkZk5wDuf2q52PN43jc4T9OkoXZ0arWZVef
# fvMr/iiIROSCzKoDmWABDRzV/UiQ5vqsaeFaqQdzFf4ed8peNWh1OaZXnYvZQgWx
# /SXiJDRSAolRzZEZquE6cbcH747FHncs/Kzcn0Ccv2jrOW+LPmnOyB+tAfiWu01T
# PhCr9VrkxsHC5qFNxaThTG5j4/Kc+ODD2dX/fmBECELcvzUHf9shoFvrn35XGf2R
# PaNTO2uSZ6n9otv7jElspkfK9qEATHZcodp+R4q2OIypxR//YEb3fkDn3UayWW9b
# AgMBAAGjggFkMIIBYDAfBgNVHSMEGDAWgBQy65Ka/zWWSC8oQEJwIDaRXBeF5jAd
# BgNVHQ4EFgQUDyrLIIcouOxvSK4rVKYpqhekzQwwDgYDVR0PAQH/BAQDAgGGMBIG
# A1UdEwEB/wQIMAYBAf8CAQAwEwYDVR0lBAwwCgYIKwYBBQUHAwMwGwYDVR0gBBQw
# EjAGBgRVHSAAMAgGBmeBDAEEATBLBgNVHR8ERDBCMECgPqA8hjpodHRwOi8vY3Js
# LnNlY3RpZ28uY29tL1NlY3RpZ29QdWJsaWNDb2RlU2lnbmluZ1Jvb3RSNDYuY3Js
# MHsGCCsGAQUFBwEBBG8wbTBGBggrBgEFBQcwAoY6aHR0cDovL2NydC5zZWN0aWdv
# LmNvbS9TZWN0aWdvUHVibGljQ29kZVNpZ25pbmdSb290UjQ2LnA3YzAjBggrBgEF
# BQcwAYYXaHR0cDovL29jc3Auc2VjdGlnby5jb20wDQYJKoZIhvcNAQEMBQADggIB
# AAb/guF3YzZue6EVIJsT/wT+mHVEYcNWlXHRkT+FoetAQLHI1uBy/YXKZDk8+Y1L
# oNqHrp22AKMGxQtgCivnDHFyAQ9GXTmlk7MjcgQbDCx6mn7yIawsppWkvfPkKaAQ
# siqaT9DnMWBHVNIabGqgQSGTrQWo43MOfsPynhbz2Hyxf5XWKZpRvr3dMapandPf
# YgoZ8iDL2OR3sYztgJrbG6VZ9DoTXFm1g0Rf97Aaen1l4c+w3DC+IkwFkvjFV3jS
# 49ZSc4lShKK6BrPTJYs4NG1DGzmpToTnwoqZ8fAmi2XlZnuchC4NPSZaPATHvNIz
# t+z1PHo35D/f7j2pO1S8BCysQDHCbM5Mnomnq5aYcKCsdbh0czchOm8bkinLrYrK
# pii+Tk7pwL7TjRKLXkomm5D1Umds++pip8wH2cQpf93at3VDcOK4N7EwoIJB0kak
# 6pSzEu4I64U6gZs7tS/dGNSljf2OSSnRr7KWzq03zl8l75jy+hOds9TWSenLbjBQ
# UGR96cFr6lEUfAIEHVC1L68Y1GGxx4/eRI82ut83axHMViw1+sVpbPxg51Tbnio1
# lB93079WPFnYaOvfGAA0e0zcfF/M9gXr+korwQTh2Prqooq2bYNMvUoUKD85gnJ+
# t0smrWrb8dee2CvYZXD5laGtaAxOfy/VKNmwuWuAh9kcMIIGoTCCBQmgAwIBAgIR
# AIhI2OgKh24UruOInRTgJ3wwDQYJKoZIhvcNAQEMBQAwVDELMAkGA1UEBhMCR0Ix
# GDAWBgNVBAoTD1NlY3RpZ28gTGltaXRlZDErMCkGA1UEAxMiU2VjdGlnbyBQdWJs
# aWMgQ29kZSBTaWduaW5nIENBIFIzNjAeFw0yMTA3MDIwMDAwMDBaFw0yNDA3MDEy
# MzU5NTlaMH8xCzAJBgNVBAYTAlVTMRIwEAYDVQQIDAlMb3Vpc2lhbmExFDASBgNV
# BAcMC1lvdW5nc3ZpbGxlMSIwIAYDVQQKDBlUZWNoUHVsc2UgQ29uc3VsdGluZywg
# TExDMSIwIAYDVQQDDBlUZWNoUHVsc2UgQ29uc3VsdGluZywgTExDMIICIjANBgkq
# hkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAyhiJxCnK78RUetV4sIrhH1rGjWI8h2zF
# bdeYYXZ1hm1VKxLN/ItQ2VUj4DlpGKIR2cl03LilRim0eZNn/2tpKIiVBNxpI/gN
# TXMebZzjKan0w2pDaOeIcsJcBoqhOgtAwHGs0T1F50QllglLSzJ6bXXE6UmP1Oz1
# GxajfEnAp2hivLqANioTZ8A9xF3cRjLx2B37TbSgEH6pR6i2Qk1oK0Git8tun0os
# 3LmLkAEX3Lv8RCqvZ8Rie2pNXG1JiWpkiOrCK+njbdCVYufvZiX1GanqRB9gWRS6
# 5DFm4LA22YyQ8Xktw34sBhk63pbknQBqnVsmwIUtn7EI7fnCdFj8YpOXicUYOILm
# zpYXK61cLngIRi3MSGpvKaMd8qmaj2zg4EsVsP3uz4InKzEyrhXO0UPYnpYhlmen
# sj/YgdxvZZOuadMGWrnAatAvtYnOki6Zp1/gzc1y2UYZi5cAS5C/wVb1+MleMUDb
# ut/IBdirT+WBxQXetoH/zuTmbElDmr9fc4A8LvlPEZ3DW8FJPlLVj6Q/N8d+wP4w
# alSE6k0JRD25tomjHiEiI5+Za6aNmIeYuV4fV8ZhTmEbm0/l/7YQ4hlcXEI5C/Ts
# qOevu4Hli/PZpNarP7vPj90rnlVOW4h/k8ZujU+HLZojOqxVMC95HsWuYBj8lF93
# O5zItMBhplUCAwEAAaOCAcEwggG9MB8GA1UdIwQYMBaAFA8qyyCHKLjsb0iuK1Sm
# KaoXpM0MMB0GA1UdDgQWBBRs+zF98PDuEvuzHBRP3h6h0vMGvDAOBgNVHQ8BAf8E
# BAMCB4AwDAYDVR0TAQH/BAIwADATBgNVHSUEDDAKBggrBgEFBQcDAzARBglghkgB
# hvhCAQEEBAMCBBAwSgYDVR0gBEMwQTA1BgwrBgEEAbIxAQIBAwIwJTAjBggrBgEF
# BQcCARYXaHR0cHM6Ly9zZWN0aWdvLmNvbS9DUFMwCAYGZ4EMAQQBMEkGA1UdHwRC
# MEAwPqA8oDqGOGh0dHA6Ly9jcmwuc2VjdGlnby5jb20vU2VjdGlnb1B1YmxpY0Nv
# ZGVTaWduaW5nQ0FSMzYuY3JsMHkGCCsGAQUFBwEBBG0wazBEBggrBgEFBQcwAoY4
# aHR0cDovL2NydC5zZWN0aWdvLmNvbS9TZWN0aWdvUHVibGljQ29kZVNpZ25pbmdD
# QVIzNi5jcnQwIwYIKwYBBQUHMAGGF2h0dHA6Ly9vY3NwLnNlY3RpZ28uY29tMCMG
# A1UdEQQcMBqBGHN1cHBvcnRAdGVjaHB1bHNlbGxjLmNvbTANBgkqhkiG9w0BAQwF
# AAOCAYEAirHinZHK6nAOPaoZFU7YyCI5urTJcZ3mDkvDllqDG44dTES0Nvkj6wOK
# SOeWaPKSgLm1SgbatNIXWP1PDmVyMHqz0wh14j9C3SIfjhVC/nbDC9ETI2qfv/dx
# e35PEUTXEpUU7ZkV8fzqFv/+KzwKEFzpmhq+RWyrnjPLH9lxevNXdwUOGoSoLST2
# JF3vYwwgwqK8lHaZ8klmCQgKrpMXdpXheNalLlXXDdcDTselOctXoa3HxNskQIgd
# dKWSkIqCtHlxhEST64023wahFGJWQJ4oF5ab2vCtiLPaoob1pkCiYf2mfw7TzfFI
# Fxem1bBbELDrMxJI803aN7uqwQ0PVsLjmsXIuH7lT7DqWAP+w0pxBm4TdFxfQQYa
# Gh9eMq/FbQwoLXCoGgBog9xwQU5LseUlWOpexLsXYIPpuH2y+TOpZ9Hjr+hDzRrw
# WpGXwtRNme0ymCM/WYcDN/zu/VtpbJ/uTi4GwwLGiJVdYO++cfq8cLyYmIbOYXp5
# EUXQd8UTMIIG7DCCBNSgAwIBAgIQMA9vrN1mmHR8qUY2p3gtuTANBgkqhkiG9w0B
# AQwFADCBiDELMAkGA1UEBhMCVVMxEzARBgNVBAgTCk5ldyBKZXJzZXkxFDASBgNV
# BAcTC0plcnNleSBDaXR5MR4wHAYDVQQKExVUaGUgVVNFUlRSVVNUIE5ldHdvcmsx
# LjAsBgNVBAMTJVVTRVJUcnVzdCBSU0EgQ2VydGlmaWNhdGlvbiBBdXRob3JpdHkw
# HhcNMTkwNTAyMDAwMDAwWhcNMzgwMTE4MjM1OTU5WjB9MQswCQYDVQQGEwJHQjEb
# MBkGA1UECBMSR3JlYXRlciBNYW5jaGVzdGVyMRAwDgYDVQQHEwdTYWxmb3JkMRgw
# FgYDVQQKEw9TZWN0aWdvIExpbWl0ZWQxJTAjBgNVBAMTHFNlY3RpZ28gUlNBIFRp
# bWUgU3RhbXBpbmcgQ0EwggIiMA0GCSqGSIb3DQEBAQUAA4ICDwAwggIKAoICAQDI
# GwGv2Sx+iJl9AZg/IJC9nIAhVJO5z6A+U++zWsB21hoEpc5Hg7XrxMxJNMvzRWW5
# +adkFiYJ+9UyUnkuyWPCE5u2hj8BBZJmbyGr1XEQeYf0RirNxFrJ29ddSU1yVg/c
# yeNTmDoqHvzOWEnTv/M5u7mkI0Ks0BXDf56iXNc48RaycNOjxN+zxXKsLgp3/A2U
# Urf8H5VzJD0BKLwPDU+zkQGObp0ndVXRFzs0IXuXAZSvf4DP0REKV4TJf1bgvUac
# gr6Unb+0ILBgfrhN9Q0/29DqhYyKVnHRLZRMyIw80xSinL0m/9NTIMdgaZtYClT0
# Bef9Maz5yIUXx7gpGaQpL0bj3duRX58/Nj4OMGcrRrc1r5a+2kxgzKi7nw0U1BjE
# MJh0giHPYla1IXMSHv2qyghYh3ekFesZVf/QOVQtJu5FGjpvzdeE8NfwKMVPZIMC
# 1Pvi3vG8Aij0bdonigbSlofe6GsO8Ft96XZpkyAcSpcsdxkrk5WYnJee647BeFbG
# RCXfBhKaBi2fA179g6JTZ8qx+o2hZMmIklnLqEbAyfKm/31X2xJ2+opBJNQb/HKl
# FKLUrUMcpEmLQTkUAx4p+hulIq6lw02C0I3aa7fb9xhAV3PwcaP7Sn1FNsH3jYL6
# uckNU4B9+rY5WDLvbxhQiddPnTO9GrWdod6VQXqngwIDAQABo4IBWjCCAVYwHwYD
# VR0jBBgwFoAUU3m/WqorSs9UgOHYm8Cd8rIDZsswHQYDVR0OBBYEFBqh+GEZIA/D
# QXdFKI7RNV8GEgRVMA4GA1UdDwEB/wQEAwIBhjASBgNVHRMBAf8ECDAGAQH/AgEA
# MBMGA1UdJQQMMAoGCCsGAQUFBwMIMBEGA1UdIAQKMAgwBgYEVR0gADBQBgNVHR8E
# STBHMEWgQ6BBhj9odHRwOi8vY3JsLnVzZXJ0cnVzdC5jb20vVVNFUlRydXN0UlNB
# Q2VydGlmaWNhdGlvbkF1dGhvcml0eS5jcmwwdgYIKwYBBQUHAQEEajBoMD8GCCsG
# AQUFBzAChjNodHRwOi8vY3J0LnVzZXJ0cnVzdC5jb20vVVNFUlRydXN0UlNBQWRk
# VHJ1c3RDQS5jcnQwJQYIKwYBBQUHMAGGGWh0dHA6Ly9vY3NwLnVzZXJ0cnVzdC5j
# b20wDQYJKoZIhvcNAQEMBQADggIBAG1UgaUzXRbhtVOBkXXfA3oyCy0lhBGysNsq
# fSoF9bw7J/RaoLlJWZApbGHLtVDb4n35nwDvQMOt0+LkVvlYQc/xQuUQff+wdB+P
# xlwJ+TNe6qAcJlhc87QRD9XVw+K81Vh4v0h24URnbY+wQxAPjeT5OGK/EwHFhaNM
# xcyyUzCVpNb0llYIuM1cfwGWvnJSajtCN3wWeDmTk5SbsdyybUFtZ83Jb5A9f0Vy
# wRsj1sJVhGbks8VmBvbz1kteraMrQoohkv6ob1olcGKBc2NeoLvY3NdK0z2vgwY4
# Eh0khy3k/ALWPncEvAQ2ted3y5wujSMYuaPCRx3wXdahc1cFaJqnyTdlHb7qvNhC
# g0MFpYumCf/RoZSmTqo9CfUFbLfSZFrYKiLCS53xOV5M3kg9mzSWmglfjv33sVKR
# zj+J9hyhtal1H3G/W0NdZT1QgW6r8NDT/LKzH7aZlib0PHmLXGTMze4nmuWgwAxy
# h8FuTVrTHurwROYybxzrF06Uw3hlIDsPQaof6aFBnf6xuKBlKjTg3qj5PObBMLvA
# oGMs/FwWAKjQxH/qEZ0eBsambTJdtDgJK0kHqv3sMNrxpy/Pt/360KOE2See+wFm
# d7lWEOEgbsausfm2usg1XTN2jvF8IAwqd661ogKGuinutFoAsYyr4/kKyVRd1Llq
# dJ69SK6YMIIG9TCCBN2gAwIBAgIQOUwl4XygbSeoZeI72R0i1DANBgkqhkiG9w0B
# AQwFADB9MQswCQYDVQQGEwJHQjEbMBkGA1UECBMSR3JlYXRlciBNYW5jaGVzdGVy
# MRAwDgYDVQQHEwdTYWxmb3JkMRgwFgYDVQQKEw9TZWN0aWdvIExpbWl0ZWQxJTAj
# BgNVBAMTHFNlY3RpZ28gUlNBIFRpbWUgU3RhbXBpbmcgQ0EwHhcNMjMwNTAzMDAw
# MDAwWhcNMzQwODAyMjM1OTU5WjBqMQswCQYDVQQGEwJHQjETMBEGA1UECBMKTWFu
# Y2hlc3RlcjEYMBYGA1UEChMPU2VjdGlnbyBMaW1pdGVkMSwwKgYDVQQDDCNTZWN0
# aWdvIFJTQSBUaW1lIFN0YW1waW5nIFNpZ25lciAjNDCCAiIwDQYJKoZIhvcNAQEB
# BQADggIPADCCAgoCggIBAKSTKFJLzyeHdqQpHJk4wOcO1NEc7GjLAWTkis13sHFl
# gryf/Iu7u5WY+yURjlqICWYRFFiyuiJb5vYy8V0twHqiDuDgVmTtoeWBIHIgZEFs
# x8MI+vN9Xe8hmsJ+1yzDuhGYHvzTIAhCs1+/f4hYMqsws9iMepZKGRNcrPznq+kc
# Fi6wsDiVSs+FUKtnAyWhuzjpD2+pWpqRKBM1uR/zPeEkyGuxmegN77tN5T2MVAOR
# 0Pwtz1UzOHoJHAfRIuBjhqe+/dKDcxIUm5pMCUa9NLzhS1B7cuBb/Rm7HzxqGXtu
# uy1EKr48TMysigSTxleGoHM2K4GX+hubfoiH2FJ5if5udzfXu1Cf+hglTxPyXnyp
# sSBaKaujQod34PRMAkjdWKVTpqOg7RmWZRUpxe0zMCXmloOBmvZgZpBYB4DNQnWs
# +7SR0MXdAUBqtqgQ7vaNereeda/TpUsYoQyfV7BeJUeRdM11EtGcb+ReDZvsdSbu
# /tP1ki9ShejaRFEqoswAyodmQ6MbAO+itZadYq0nC/IbSsnDlEI3iCCEqIeuw7oj
# cnv4VO/4ayewhfWnQ4XYKzl021p3AtGk+vXNnD3MH65R0Hts2B0tEUJTcXTC5TWq
# LVIS2SXP8NPQkUMS1zJ9mGzjd0HI/x8kVO9urcY+VXvxXIc6ZPFgSwVP77kv7AkT
# AgMBAAGjggGCMIIBfjAfBgNVHSMEGDAWgBQaofhhGSAPw0F3RSiO0TVfBhIEVTAd
# BgNVHQ4EFgQUAw8xyJEqk71j89FdTaQ0D9KVARgwDgYDVR0PAQH/BAQDAgbAMAwG
# A1UdEwEB/wQCMAAwFgYDVR0lAQH/BAwwCgYIKwYBBQUHAwgwSgYDVR0gBEMwQTA1
# BgwrBgEEAbIxAQIBAwgwJTAjBggrBgEFBQcCARYXaHR0cHM6Ly9zZWN0aWdvLmNv
# bS9DUFMwCAYGZ4EMAQQCMEQGA1UdHwQ9MDswOaA3oDWGM2h0dHA6Ly9jcmwuc2Vj
# dGlnby5jb20vU2VjdGlnb1JTQVRpbWVTdGFtcGluZ0NBLmNybDB0BggrBgEFBQcB
# AQRoMGYwPwYIKwYBBQUHMAKGM2h0dHA6Ly9jcnQuc2VjdGlnby5jb20vU2VjdGln
# b1JTQVRpbWVTdGFtcGluZ0NBLmNydDAjBggrBgEFBQcwAYYXaHR0cDovL29jc3Au
# c2VjdGlnby5jb20wDQYJKoZIhvcNAQEMBQADggIBAEybZVj64HnP7xXDMm3eM5Hr
# d1ji673LSjx13n6UbcMixwSV32VpYRMM9gye9YkgXsGHxwMkysel8Cbf+PgxZQ3g
# 621RV6aMhFIIRhwqwt7y2opF87739i7Efu347Wi/elZI6WHlmjl3vL66kWSIdf9d
# hRY0J9Ipy//tLdr/vpMM7G2iDczD8W69IZEaIwBSrZfUYngqhHmo1z2sIY9wwyR5
# OpfxDaOjW1PYqwC6WPs1gE9fKHFsGV7Cg3KQruDG2PKZ++q0kmV8B3w1RB2tWBhr
# YvvebMQKqWzTIUZw3C+NdUwjwkHQepY7w0vdzZImdHZcN6CaJJ5OX07Tjw/lE09Z
# RGVLQ2TPSPhnZ7lNv8wNsTow0KE9SK16ZeTs3+AB8LMqSjmswaT5qX010DJAoLEZ
# Khghssh9BXEaSyc2quCYHIN158d+S4RDzUP7kJd2KhKsQMFwW5kKQPqAbZRhe8hu
# uchnZyRcUI0BIN4H9wHU+C4RzZ2D5fjKJRxEPSflsIZHKgsbhHZ9e2hPjbf3E7Tt
# oC3ucw/ZELqdmSx813UfjxDElOZ+JOWVSoiMJ9aFZh35rmR2kehI/shVCu0pwx/e
# OKbAFPsyPfipg2I2yMO+AIccq/pKQhyJA9z1XHxw2V14Tu6fXiDmCWp8KwijSPUV
# /ARP380hHHrl9Y4a1LlAMYIGMTCCBi0CAQEwaTBUMQswCQYDVQQGEwJHQjEYMBYG
# A1UEChMPU2VjdGlnbyBMaW1pdGVkMSswKQYDVQQDEyJTZWN0aWdvIFB1YmxpYyBD
# b2RlIFNpZ25pbmcgQ0EgUjM2AhEAiEjY6AqHbhSu44idFOAnfDANBglghkgBZQME
# AgEFAKBMMBkGCSqGSIb3DQEJAzEMBgorBgEEAYI3AgEEMC8GCSqGSIb3DQEJBDEi
# BCBDHBa7ntd2SvEWUPjKE1cJuwMOBRddwjDI6CHYQkWBojANBgkqhkiG9w0BAQEF
# AASCAgAUxlmxzDwR18o0tNZEmMktAeuxpqj4CaIqv67zfJK5UQ0PP0Gw21gSoLqG
# 5AozfmRc2sra1FzNlHSPfDpU8Rg4lnTcMcYywmYkeFiMPhlKzAuij0/iQHpKhz3Z
# n14lz1M/moQcvg4F8ZrXt/FAYS6LrZEfuFMIK884WADFtpVCPb/ijzrFYLSzAjci
# VqAV7/9QCCvCQlm7kxWL8mi+CxTIlY9TRUui7wEQiY+XVf+O73tIDCMbciH+2f3W
# J/8ktqtMh1lAJy4Nf0CFf7rcOKrwmY7QoXTNW/SxvT6ulU47SyYdwYRsd8mhcJnC
# oqpzuhZmnsoj+LJ37Q6YrbiRe7Rxor/WN2+oRtQ1/HXmzEvFdr1PE0dMPpVLE/XS
# Hz+2PgUxzxPY5VYkAmID22UZBiA+/B74KagIO0cJEMWLbMIGxq1k50AC1VI2TKmd
# f/nV5S8jtv+7EhL0/T/K3XAoBCKN6ZOfo48A2eamAySmm6YwfOKYFqOwdUiVvAGa
# u8PpkqhfJXt8hI3Irw3mIfKTo/s/hauYQQi7dLxbZtsces/gLVVJChu4OpGwBcXe
# UnPiiSd/FH02v2jY0RzXTW42JuxHIt0LXxN+viB74T6oZQCfNbrsAUJO1n+7yzhh
# 01/KEBNg4fSkGu1rEwaa+SoYxK76HffQ5xmkCCH27fU8TDE5EaGCA0swggNHBgkq
# hkiG9w0BCQYxggM4MIIDNAIBATCBkTB9MQswCQYDVQQGEwJHQjEbMBkGA1UECBMS
# R3JlYXRlciBNYW5jaGVzdGVyMRAwDgYDVQQHEwdTYWxmb3JkMRgwFgYDVQQKEw9T
# ZWN0aWdvIExpbWl0ZWQxJTAjBgNVBAMTHFNlY3RpZ28gUlNBIFRpbWUgU3RhbXBp
# bmcgQ0ECEDlMJeF8oG0nqGXiO9kdItQwDQYJYIZIAWUDBAICBQCgeTAYBgkqhkiG
# 9w0BCQMxCwYJKoZIhvcNAQcBMBwGCSqGSIb3DQEJBTEPFw0yMzA1MTAxMzM4MjJa
# MD8GCSqGSIb3DQEJBDEyBDDGoOk2bebMQ+HIinJZVP4aqKcfp5eKSR1MKtgF25Pq
# SSo4fdpRyZ14a8Hxy+TVNjcwDQYJKoZIhvcNAQEBBQAEggIAYDV2JZks6c3MUzfp
# hUkJ6q+RoHLBgQiZMulYPuvKHE920bZItw52ZSs9mit3BTCV1El/k0GDo6X8+cH7
# dPO//Rhc6M8mhr99QxO9LNO2dierK0JYuQfDvFpnkIaQV10s0dMWogvLIg7nCouJ
# vfx9IGTbCIRnS9YizGmvvXlneJje6OT3BbUowDmo8ZWXt0U2sgk1y/P27rMbwPJV
# HFyMHBsWYcrvcPkPXweAv7F5e/ZtHrJl/Fw1WIYWNnJkhW67hzCAR2zsP4gnhXog
# 9RUrKIsqUqWeZUX+/vxHfW+1D7VzMwTKuMGV/pnxNU5hBT2r8tkOvsEMzRgTA8ZH
# 6XFg58rAhrM+Omzi37HUTFO2UJnRuGYgNzCwo+n+Q9geI/ErKK+QZB0aiXdB3NG1
# 5uHkmYscUTd1145O59N/mG9umGFhcnxE4eqzDRBm1rlVsOTQ9HBIg0MNX1KIsHKj
# iN3t5wPaGAiAA7IVffZdjC5CQ4t0hZ2ITVOFuRNSPVV9rQ+IJrRDatz9/tBijSuV
# I85mmtmoHUwXizdwxUJD+aCd1GanCkXGPl1xDtHyN8igygo39Qwt1JaIh98YtAle
# Gf5BAxXgBQWQvd9hp9YHC+rx+n9NRDARYbGz8UIdvIGMau9fqABvqIxLbcZ40NV2
# pN+CeZuR5iEp+3AEe2Wu2r+QO1M=
# SIG # End signature block
