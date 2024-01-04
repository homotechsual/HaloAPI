function Get-HaloSuppliersFromQBO {
    param[
        [int32]$ConnectionID,
        [string]$datatype = 'vendor'
    ]

    $QSCollection = New-HaloQuery -CommandName $CommandName -Parameters $Parameters -IsMulti
    $Resource = 'api/integrationdata/get/quickbooksonline'
    $RequestParams = @{
        Method = 'GET'
        Resource = $Resource
        AutoPaginateOff = $Paginate
        QSCollection = $QSCollection
        ResourceType = 'releases'
    }
    
    $QBOVendors = New-HaloGETRequest @RequestParams
    Return $QBOVendors
}