function New-Passphrase {
    [CmdletBinding()]
    [OutputType([string])]
    Param (
        [Parameter(
            Mandatory = $false,
            Position = 0,
            HelpMessage = 'Amount of words to get')]
        [ValidateNotNullOrEmpty()]
        [int]
        $AmountOfWords = 3,
        [Parameter(
            Mandatory = $false,
            Position = 3,
            HelpMessage = 'Separator to use between words')]
        [ValidateNotNullOrEmpty()]
        [string]
        $Separator = " ",
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Includes numbers')]
        [switch]
        $IncludeNumbers,
        [Parameter(
            Mandatory = $false,
            Position = 1,
            HelpMessage = 'Amount of numbers to include')]
        [ValidateNotNullOrEmpty()]
        [int]
        $AmountOfNumbers = 1,
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Include an uppercase word')]
        [switch]
        $IncludeUppercase,
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Include special characters')]
        [switch]
        $IncludeSpecials,
        [Parameter(
            Mandatory = $false,
            Position = 2,
            HelpMessage = 'Amount of special characters to include')]
        [int]
        $AmountOfSpecials = 1
    )
    $ErrorActionPreference = 'Stop'
    $InformationPreference = 'Continue'
    try {
        [array]$Words = . (Join-Path (Split-Path $PSScriptroot) 'private\Passphraser.Words.ps1')
        [char[]]$SpecialCharacters = '!"#$%&()*+,-./:;<=>?@\^_{|}' |
            ForEach-Object {
                [char[]]$_
            }
        [string]$PasswordString = ($Words |
            Get-Random -Count $AmountOfWords
        ) -join $Separator
        if ($IncludeUppercase) {
            [string]$Word = $PasswordString.Split($Separator) |
                Get-Random
            [string]$PasswordString = $PasswordString.Replace(
                $Word,
                $Word.ToUpper()
            )
        }
        if ($IncludeNumbers) {
            for ($i = 1; $i -le $AmountOfNumbers; $i++) {
                [int]$Number = (0..9) |
                    Get-Random
                [string]$Word = $PasswordString.Split($Separator) |
                    Get-Random
                [int]$Placement = @(
                    0,
                    $Word.Length
                ) | Get-Random
                [string]$WordWithNumber = $Word.Insert(
                    $Placement,
                    $Number
                )
                [string]$PasswordString = $PasswordString.Replace(
                    $Word,
                    $WordWithNumber
                )
            }
        }
        if ($IncludeSpecials) {
            for ($i = 1; $i -le $AmountOfSpecials; $i++) {
                [char[]]$Special = $SpecialCharacters |
                    Get-Random
                [string]$Word = $PasswordString.Split($Separator) |
                    Get-Random
                [int]$Placement = @(
                    0,
                    $Word.Length
                ) | Get-Random
                [string]$WordWithSpecial = $Word.Insert(
                    $Placement,
                    $Special
                )
                [string]$PasswordString = $PasswordString.Replace(
                    $Word,
                    $WordWithSpecial
                )
            }
        }
        return $PasswordString
    } catch {
        $PSCmdlet.throwTerminatingError($PSItem)
    }
}
