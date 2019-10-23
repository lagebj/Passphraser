[cmdletbinding()]
param()

Write-Verbose 'Import everything in sub folders'
foreach ($folder in @('classes', 'scripts')) {
    $root = Join-Path -Path $PSScriptRoot -ChildPath $folder
    if (Test-Path -Path $root) {
        Write-Verbose "processing folder $root"
        $files = Get-ChildItem -Path $root -Filter *.ps1 -Recurse

        # dot source each file
        $files | where-Object { $_.name -NotLike '*.Tests.ps1' } | 
        ForEach-Object { Write-Verbose $_.basename; . $_.FullName }
    }
}

Export-ModuleMember -function (Get-ChildItem -Path "$PSScriptRoot\scripts\*.ps1").basename