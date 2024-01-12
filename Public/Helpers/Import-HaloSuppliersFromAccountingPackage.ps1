function Import-HaloSupplierFromQBO {
    <#
        .SYNOPSIS
            Imports Halo Suppliers from QuickBooks Online
        .DESCRIPTION
            Imports Halo Suppliers from QuickBooks Online into the Halo API.
        .OUTPUTS
            A powershell object containing the response.
    #>
    [CmdletBinding()]
    param (
        [Parameter()]
        [System.Object]
        $APSupplier,
        [Parameter()]
        [string]
        $ImportType = 'quickbooksonline',
        [Parameter()]
        [string]
        $APCompanyID
    )
    [PSCustomObject]$returnData = @{
        _isimport = $true
        _importtype = $ImportType
        accounts_id = $APSupplier.id
        details_id = 1
        qbo_company_id = $APCompanyID
        name = $APSupplier.companyName
        address = "$($APSupplier.billAddr.line1)`n$($APSupplier.billAddr.city)`n$($APSupplier.billAddr.countrySubDivisionCode)`n$($APSupplier.billAddr.postalCode)"        
    }

    if ($Email = $APSupplier.primaryEmailAddr.address) {
        Add-Member -InputObject $returnData -Name email_address -Value $Email -MemberType NoteProperty -Force
    }
    if ($PhoneNumber = $APSupplier.printOnCheckName.freeFormNumber) {
        Add-Member -InputObject $returnData -Name phone_number -Value $PhoneNumber -MemberType NoteProperty -Force
    }

    if (($FirstName = $APSupplier.givenName) -or ($LastName = $APSupplier.familyName)) {
        Add-Member -InputObject $returnData -Name contact_name -Value ("$($FirstName) $($LastName)".trim()) -MemberType NoteProperty -Force
    }
    return $returnData
}