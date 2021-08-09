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
    $Script:ManifestHash = Invoke-Expression -Command (Get-Content $ManifestPath -Raw)
}

# Test that the manifest is generally correct. Not a functional test.
Describe -Name 'Core' -Fixture {
    It -Name 'Manifest is valid' -Test {
        {
            Test-ModuleManifest -Path $ManifestPath -ErrorAction Stop -WarningAction SilentlyContinue
        } | Should -Not -Throw
    }

    It -Name 'Root module is correct' -Test {
        $Script:ManifestHash.RootModule | Should -Be ".\$($ModuleName).psm1"
    }

    It -Name 'Has a description' -Test {
        $Script:ManifestHash.Description | Should -Not -BeNullOrEmpty
    }

    It -Name 'GUID is correct' -Test {
        $Script:ManifestHash.GUID | Should -Be '8bc83215-4735-4029-9f40-e05fe3e8f73b'
    }

    It -Name 'Version is valid' -Test {
        $Script:ManifestHash.ModuleVersion -As [Version] | Should -Not -BeNullOrEmpty
    }

    It -Name 'Copyright is present' -Test {
        $Script:ManifestHash.Copyright | Should -Not -BeNullOrEmpty
    }

    It -Name 'License URI is correct' -Test {
        $Script:ManifestHash.PrivateData.Values.LicenseUri | Should -Be 'https://haloapi.mit-license.org/'
    }

    It -Name 'Project URI is correct' -Test {
        $Script:ManifestHash.PrivateData.Values.ProjectUri | Should -Be 'https://github.com/homotechsual/HaloAPI'
    }

    It -Name "PowerShell Gallery tags do not contain spaces" -Test {
        foreach ($Tag in $Script:ManifestHash.PrivateData.Values.tags) {
            $Tag -NotMatch '\s' | Should -Be $True
        }
    }
}


Describe -Name 'Module HaloAPI loads' -Fixture {
    It -Name 'Passed Module load' -Test {
        Get-Module -Name 'HaloAPI' | Should -Not -Be $null
    }
}