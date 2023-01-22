#Requires -Modules psake

Invoke-PSake -BuildFile ('{0}\Passphraser.Build.ps1' -f $PSScriptRoot) -taskList 'Publish'
