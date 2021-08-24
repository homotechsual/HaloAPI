#Requires -Version 7
$Functions = @(Get-ChildItem -Path $PSScriptRoot\Public\ -Include *.ps1 -Recurse) + @(Get-ChildItem -Path $PSScriptRoot\Private\ -Include *.ps1 -Recurse)
# Import functions.
foreach ($Function in @($Functions)) {
    try {
        Write-Verbose "Importing function $($Function.FullName)"
        . $Function.FullName
    } catch {
        Write-Error -Message "Failed to import function $($Function.FullName): $_"
    }
}
[int32]$Script:HAPIDefaultPageSize = 2000
New-Alias -Name 'Get-HaloArticle' -Value Get-HaloKBArticle
New-Alias -Name 'New-HaloArticle' -Value New-HaloKBArticle
New-Alias -Name 'Set-HaloArticle' -Value Set-HaloKBArticle
Export-ModuleMember -Function $Functions.BaseName -Alias *