
function Get-HaloNullObject {
    <#
        .SYNOPSIS
            Nulls all values of an object
        .DESCRIPTION
            Provides an null object for use in provisioning items in the Halo API
        .OUTPUTS
            A powershell object containing the response.
    #>
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param(
        [Parameter( Mandatory = $True )]
        [PSCustomObject]$NullObject
    )
    $NullObject.PSObject.Properties | ForEach-Object {
        Write-Verbose "Attribute Name: $($_.name)"
        Write-Verbose "Attribute Type: $(($_.Value.GetType()).name)"
        if ($_.Value -isnot [PSCustomObject]) {
            $_.Value = $Null
        } else {
            $_.Value = Get-HaloNullObject -NullObject $_.Value
        }
    }
    return $NullObject
}