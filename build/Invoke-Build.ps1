<#
.Description
Installs and loads all the required modules for the build.
Derived from scripts written by Warren F. (RamblingCookieMonster)
#>

[cmdletbinding()]
param ($Task = 'Default')

Write-Output "Starting build"

if (-not (Get-PackageProvider | ? Name -eq nuget)) {
    Write-Output "  Install Nuget PS package provider"
    Install-PackageProvider -Name NuGet -Force -Confirm:$false | Out-Null
}

$publishRepository = 'PSGallery'

# Grab nuget bits, install modules, set build variables, start build.
if (-not (Get-Item env:\BH*)) {
    Set-BuildEnvironment
    Set-Item env:\PublishRepository -Value $publishRepository
}

Write-Output "  Install And Import Build Modules"
if (-not(Get-InstalledModule PSDepend -ErrorAction SilentlyContinue)) {
    Install-Module PSDepend -Force -Scope CurrentUser
}
Import-Module PSDepend
Invoke-PSDepend -Path "$PSScriptRoot\build\$env:BHProjectName.Depend.psd1" -Install -Import -Force

Write-Output "  Invoke build"
try {
    Invoke-psake -buildFile "$PSScriptRoot\$env:BHProjectName.Build.ps1" -taskList $Task
    exit 0
} catch {
    exit 1
}