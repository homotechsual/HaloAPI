<#
    .SYNOPSIS
        Core test suite for the HaloAPI module.
#>

BeforeAll {
    $ModulePath = Split-Path -Parent -Path (Split-Path -Parent -Path $PSCommandPath)
    $ModuleName = 'HaloAPI'
    $ManifestPath = "$ModulePath\$ModuleName.psd1"
    if (Get-Module -Name $ModuleName) {
        Remove-Module $ModuleName -Force
    }
    Import-Module $ManifestPath -Verbose:$False
    $Script:ManifestHash = Get-Content $ManifestPath -Raw
}

# Test that the manifest is generally correct. Not a functional test.
Describe 'Core' {
    It 'Manifest is valid' {
        {
            Test-ModuleManifest -Path $ManifestPath -ErrorAction Stop -WarningAction SilentlyContinue
        } | Should -Not -Throw
    }

    It 'Root module is correct' {
        $Script:ManifestHash.RootModule | Should -Be ".\$($ModuleName).psm1"
    }

    It 'Has a description' {
        $Script:ManifestHash.Description | Should -Not -BeNullOrEmpty
    }

    It 'GUID is correct' {
        $Script:ManifestHash.GUID | Should -Be '8bc83215-4735-4029-9f40-e05fe3e8f73b'
    }

    It 'Version is valid' {
        $Script:ManifestHash.ModuleVersion -As [Version] | Should -Not -BeNullOrEmpty
    }

    It 'Copyright is present' {
        $Script:ManifestHash.Copyright | Should -Not -BeNullOrEmpty
    }

    It 'License URI is correct' {
        $Script:ManifestHash.PrivateData.Values.LicenseUri | Should -Be 'https://haloapi.mit-license.org/'
    }

    It 'Project URI is correct' {
        $Script:ManifestHash.PrivateData.Values.ProjectUri | Should -Be 'https://github.com/homotechsual/HaloAPI'
    }

    It 'PowerShell Gallery tags do not contain spaces' {
        foreach ($Tag in $Script:ManifestHash.PrivateData.Values.tags) {
            $Tag -NotMatch '\s' | Should -Be $True
        }
    }
}

Describe 'Module HaloAPI loads' {
    It 'Passed Module load' {
        Get-Module -Name 'HaloAPI' | Should -Not -Be $null
    }
}