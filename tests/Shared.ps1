[string] $ModuleRootDir = Split-Path -Path $PSScriptRoot

[string] $ModuleName = Get-Item -Path ('{0}\*.psd1' -f $ModuleRootDir) |
    Where-Object -FilterScript {$null -ne (Test-ModuleManifest -Path $PSItem -ErrorAction 'SilentlyContinue')} |
    Select-Object -First 1 -ExpandProperty 'BaseName'

[System.Diagnostics.CodeAnalysis.SuppressMessage('PSUseDeclaredVarsMoreThanAssigments', '')]
[System.Management.Automation.PSModuleInfo[]] $PassphraserModule = Import-Module "$ModuleRootDir\$ModuleName.psd1" -Scope Global -PassThru
