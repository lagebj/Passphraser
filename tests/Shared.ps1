$ModuleRootDir = (Split-Path $PSScriptRoot)
$ModuleName = Get-Item $ModuleRootDir\*.psd1 |
        Where-Object { $null -ne (Test-ModuleManifest -Path $_ -ErrorAction SilentlyContinue) } |
        Select-Object -First 1 |
        Foreach-Object BaseName
[System.Diagnostics.CodeAnalysis.SuppressMessage('PSUseDeclaredVarsMoreThanAssigments', '')]
$PassphraserModule = Import-Module "$ModuleRootDir\$ModuleName.psd1" -Scope Global -PassThru