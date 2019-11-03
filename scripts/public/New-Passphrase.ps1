﻿function New-Passphrase {
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
            HelpMessage = 'Separator to use between words')]
        [ValidateNotNullOrEmpty()]
        [string]
        $Separator = " ",
        [Parameter(
            HelpMessage = 'Includes numbers')]
        [switch]
        $IncludeNumbers,
        [Parameter(
            HelpMessage = 'Amount of numbers to include')]
        [ValidateNotNullOrEmpty()]
        [int]
        $AmountOfNumbers = 1,
        [Parameter(
            HelpMessage = 'Include an uppercase word')]
        [switch]
        $IncludeUppercase
    )
    $ErrorActionPreference = 'Stop'
    $InformationPreference = 'Continue'
    # Load common variables
    $Words = . (Join-Path (Split-Path $PSScriptroot) 'private\Passphraser.Words.ps1')
    # Set query
    try {
        [string]$PasswordString = (
            $Words |
            Get-Random -Count $AmountOfWords -ErrorAction SilentlyContinue
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
        return $PasswordString
    } catch {
        $PSCmdlet.throwTerminatingError($PSItem)
    }
}
