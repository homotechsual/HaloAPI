using namespace System.Management.Automation
using module ..\HaloCustomButton.psm1

class HaloCustomButtonValidator : IValidateSetValuesGenerator {
    <#
        .SYNOPSIS
            Argument validator for Halo Custom Button types.
        .DESCRIPTION
            Provides argument validation for Halo Custom Button types.
    #>
    [string[]] GetValidValues() {
        $CustomButtonTypes = [HaloCustomButton]::GetButtonTypes()
        $Values = $($CustomButtonTypes).Keys
        return $Values
    }
}