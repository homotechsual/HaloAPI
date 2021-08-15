class HaloCustomButton {
    <#
        .SYNOPSIS
            Utility classes for Halo Custom Button types.
        .DESCRIPTION
            Provides string to ID and types listing for Halo Custom Button types.
    #>
    [hashtable] static $ButtonTypes = @{
        "Company" = 2
        "Site" = 3
        "User" = 4
        "Asset" = 5
        "Contract" = 6
        "Item" = 8
        "Supplier" = 9
        "SupplierContract" = 1001
    }
    [hashtable] static GetButtonTypes() {
        return [HaloCustomButton]::ButtonTypes
    }
    [int] static ToID([string]$CustomButtonType) {
        $Types = [HaloCustomButton]::ButtonTypes
        $TypeID = $Types.$CustomButtonType
        return $TypeID
    }
}
