class HaloLookup {
    <#
        .SYNOPSIS
            Utility classes for Halo Lookup types.
        .DESCRIPTION
            Provides string to ID and types listing for Halo Lookup types.
    #>
    static [object[]] $LookupTypes

    [object[]] static GetLookupTypes() {
        return [HaloLookup]::LookupTypes
    }
    [int] static ToID([string]$LookupType) {
        $Types = [HaloLookup]::GetLookupTypes()
        $TypeID = ($Types | Where-Object { $_.name -eq $LookupType } | Select-Object -Property id).id
        return $TypeID
    }
}
