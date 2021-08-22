using namespace System.Management.Automation
using module ..\HaloLookup.psm1

class HaloLookupValidator : IValidateSetValuesGenerator {
    <#
        .SYNOPSIS
            Argument validator for Halo Lookup types.
        .DESCRIPTION
            Provides argument validation for Halo Lookup types.
    #>
    [string[]] GetValidValues() {
        # Initialise the HaloLookup class.
        $Values = $([HaloLookup]::GetLookupTypes()).name
        return $Values
    }
}