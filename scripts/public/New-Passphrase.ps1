function New-Passphrase {
    [CmdletBinding(
        SupportsShouldProcess,
        ConfirmImpact = 'Low')]

    [OutputType(
        [string],
        [psobject])]

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
        [char]
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
        $AmountOfSpecials = 1,

        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Return passphrase as object')]
        [switch]
        $AsObject,

        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Custom string to include in passphrase')]
        [string]
        $CustomString
    )
    $ErrorActionPreference = 'Stop'
    $InformationPreference = 'Continue'
    if (-not $PSBoundParameters.ContainsKey('Verbose')) { $VerbosePreference = $PSCmdlet.SessionState.PSVariable.GetValue('VerbosePreference') }
    if (-not $PSBoundParameters.ContainsKey('Confirm')) { $ConfirmPreference = $PSCmdlet.SessionState.PSVariable.GetValue('ConfirmPreference') }
    if (-not $PSBoundParameters.ContainsKey('WhatIf')) { $WhatIfPreference = $PSCmdlet.SessionState.PSVariable.GetValue('WhatIfPreference') }
    Write-Verbose ('[{0}] Confirm={1} ConfirmPreference={2} WhatIf={3} WhatIfPreference={4}' -f $MyInvocation.MyCommand, $Confirm, $ConfirmPreference, $WhatIf, $WhatIfPreference)
    if ($PSCmdlet.ShouldProcess("Generates a new random passphrase")) {
        try {
            if ($PSBoundParameters.ContainsKey('CustomString')) {
                $Passphrase = [Passphrase]::new($CustomString, $Separator)
            } else {
                [array]$Words = . (Join-Path (Split-Path $PSScriptroot) 'private\Passphraser.Words.ps1')

                $Passphrase = [Passphrase]::new($Words, $AmountOfWords, $Separator)
            }

            if ($PSBoundParameters.ContainsKey('IncludeUppercase')) {
                $Passphrase.AddUppercase()
            }

            if ($PSBoundParameters.ContainsKey('IncludeNumbers')) {
                $Passphrase.AddNumber($AmountOfNumbers)
            }

            if ($PSBoundParameters.ContainsKey('IncludeSpecials')) {
                $Passphrase.AddSpecial($AmountOfSpecials)
            }

            if ($PSBoundParameters.ContainsKey('AsObject')) {
                return $Passphrase
            } else {
                return $Passphrase.ToString()
            }
        } catch {
            $PSCmdlet.throwTerminatingError($PSItem)
        }
    }
}
