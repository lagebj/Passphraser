[cmdletbinding()]
Param()

foreach ($Folder in @('scripts\public', 'scripts\private')) {
    [string] $Root = '{0}\{1}' -f $PSScriptRoot, $Folder
    if (Test-Path -Path $Root) {
        [System.IO.FileInfo[]] $Files = Get-ChildItem -Path $Root -Filter '*.ps1' -Recurse
        $Files | Where-Object {$PSItem.Name -NotLike '*.Tests.ps1'} | ForEach-Object {. $PSItem.FullName}
    }
}

Export-ModuleMember -Function (Get-ChildItem -Path ('{0}\scripts\public\*.ps1' -f $PSScriptRoot)).BaseName
