#Requires -Version 7
function ConvertTo-HaloAuthToken {
    <#
    .SYNOPSIS
        Converts a Halo token endpoint response into the module's auth token hashtable.
    .DESCRIPTION
        Builds the hashtable stored in $Script:HAPIAuthToken from the JSON payload returned by the Halo token endpoint.
    .OUTPUTS
        A hashtable containing the token type, access token, expiry, refresh token and id token.
    #>
    [CmdletBinding()]
    [OutputType([Hashtable])]
    param (
        # The parsed token endpoint response.
        [Parameter(
            Mandatory = $True
        )]
        [Object]$TokenPayload
    )
    return @{
        Type = $TokenPayload.token_type
        Access = $TokenPayload.access_token
        Expires = Get-TokenExpiry -ExpiresIn $TokenPayload.expires_in
        Refresh = $TokenPayload.refresh_token
        Id = $TokenPayload.id_token
    }
}
