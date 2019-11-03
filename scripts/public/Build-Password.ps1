function Build-Password {
    [CmdletBinding()]
    Param (
        [Parameter(
            Mandatory = $false,
            Position = 0,
            HelpMessage = 'Number of words to get')]
        [ValidateNotNullOrEmpty()]
        [int]
        $TotalWords = 3,
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Separator to use between words')]
        [ValidateNotNullOrEmpty()]
        [string]
        $Separator = " ",
        [Parameter(
            HelpMessage = 'Pass if output should include numbers')]
        [switch]
        $IncludeNumbers,
        [Parameter(
            HelpMessage = 'Pass if output should include numbers')]
        [ValidateNotNullOrEmpty()]
        [int]
        $TotalNumbers = 1,
        [Parameter(
            HelpMessage = 'Pass if output should include an uppercase word')]
        [switch]
        $Uppercase
    )
    $ErrorActionPreference = 'Stop'
    $InformationPreference = 'Continue'
    # Load common variables
    $Words = . "$PSScriptRoot\Nmh.Ps.PasswordManagement.Words.ps1"
    # Set query
    try {
        [string]$PasswordString = Join-String -InputObject ($Words | Get-Random -Count $TotalWords -ErrorAction SilentlyContinue) -Separator $Separator
        if ($Uppercase) {
            [string]$Word = $PasswordString.Split($Separator) | Get-Random
            [string]$PasswordString = $PasswordString.Replace($Word, $Word.ToUpper())
        }
        if ($IncludeNumbers) {
            for ($i = 1; $i -le $TotalNumbers; $i++) {
                [int]$Number = (0..9) | Get-Random
                [string]$Word = $PasswordString.Split($Separator) | Get-Random
                [int]$Placement = @(0, $Word.Length) | Get-Random
                [string]$WordWithNumber = $Word.Insert($Placement, $Number)
                [string]$PasswordString = $PasswordString.Replace($Word, $WordWithNumber)
            }
        }
        return $PasswordString
    } catch {
        $PSCmdlet.throwTerminatingError($PSItem)
    }
}

