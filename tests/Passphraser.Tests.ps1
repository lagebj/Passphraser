[string] $ModuleManifestPath = '{0}\..\Passphraser.psd1' -f $PSScriptRoot

Describe 'Module Manifest Tests' {
    It 'Passes Test-ModuleManifest' {
        Test-ModuleManifest -Path $ModuleManifestPath | Should -Not -BeNullOrEmpty
        $? | Should -Be $true
    }
}


