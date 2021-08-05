#Requires -Version 7
$Functions  = @(Get-ChildItem -Path $PSScriptRoot\Public\*.ps1) + @(Get-ChildItem -Path $PSScriptRoot\Private\*.ps1)
foreach ($Function in @($Functions)){
    try {
        . $Function.FullName
    } catch {
        Write-Error -Message "Failed to import function $($Function.FullName): $_"
    }
}
[int64]$Script:HAPITokenExpiry = 3600
Export-ModuleMember -Function $Functions.BaseName -Alias *