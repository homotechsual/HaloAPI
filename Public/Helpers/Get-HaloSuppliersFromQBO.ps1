function Get-HaloSuppliersFromQBO {
    <#
        .SYNOPSIS
            Gets QuickBooks Online suppliers from the Halo API
        .DESCRIPTION
            Retrieves QuickBooks Online suppliers from the Halo API.
        .OUTPUTS
            A powershell object containing the response.
    #>
    param(
        # The Halo <-> QuickBooks Online connection Id
        [int32]$ConnectionID,
        # The Data Type to retrieve
        [string]$DataType = 'vendor'
    )
    $QSCollection = New-HaloQuery -CommandName $CommandName -Parameters $Parameters -IsMulti
    $Resource = 'api/integrationdata/get/quickbooksonline'
    $RequestParams = @{
        Method          = 'GET'
        Resource        = $Resource
        AutoPaginateOff = $Paginate
        QSCollection    = $QSCollection
        ResourceType    = 'releases'
    }
    $QBOVendors = New-HaloGETRequest @RequestParams
    Return $QBOVendors
}