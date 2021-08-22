using namespace System.Management.Automation
using module ..\HaloAuth.psm1

class HaloAuthScopesValidator : IValidateSetValuesGenerator {
    <#
        .SYNOPSIS
            Argument validator for Halo authentication scopes.
        .DESCRIPTION
            Provides argument validation for Halo authentication scopes.
    #>
    [string[]] GetValidValues() {
        $Scopes = [HaloAuth]::GetScopes()
        $Values = $Scopes
        return $Values
    }
}