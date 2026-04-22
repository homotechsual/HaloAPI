#Requires -Version 7
$PublicPath = Join-Path -Path $PSScriptRoot -ChildPath 'Public'
$PrivatePath = Join-Path -Path $PSScriptRoot -ChildPath 'Private'
$Functions = @(Get-ChildItem -Path $PublicPath -Include *.ps1 -Recurse) + @(Get-ChildItem -Path $PrivatePath -Include *.ps1 -Recurse)
# Import functions.
foreach ($Function in @($Functions)) {
    try {
        Write-Verbose ('Importing function {0}' -f $Function.FullName)
        . $Function.FullName
    } catch {
        Write-Error -Message ('Failed to import function {0}: {1}' -f $Function.FullName, $_)
    }
}
[int32]$Script:HAPIDefaultPageSize = 1000
New-Alias -Name 'Get-HaloArticle' -Value Get-HaloKBArticle
New-Alias -Name 'New-HaloArticle' -Value New-HaloKBArticle
New-Alias -Name 'Set-HaloArticle' -Value Set-HaloKBArticle
New-Alias -Name 'New-HaloArticleBatch' -Value New-HaloKBArticleBatch
New-Alias -Name 'Get-HaloCustomFields' -Value Get-HaloCustomField
New-Alias -Name 'Get-HaloWorkflows' -Value Get-HaloWorkflow
New-Alias -Name 'Get-HaloTabs' -Value Get-HaloTab
Export-ModuleMember -Function $Functions.BaseName -Alias *