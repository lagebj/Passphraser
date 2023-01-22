Describe 'Module Manifest Tests' {
    It 'Passes Test-ModuleManifest' {
        [string] $ModuleManifestPath = '{0}\..\Passphraser.psd1' -f $PSScriptRoot
        Test-ModuleManifest -Path $ModuleManifestPath | Should -Not -BeNullOrEmpty
        $? | Should -Be $true
    }
}


