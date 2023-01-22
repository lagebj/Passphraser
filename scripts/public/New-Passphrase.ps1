function New-Passphrase {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Low', DefaultParameterSetName = 'New')]
    [OutputType([string], [PassphraseObject])]

    Param (
        [Parameter(ParameterSetName = 'New', Mandatory = $false, Position = 0, HelpMessage = 'Amount of words to include in passphrase')]
        [ValidateNotNullOrEmpty()]
        [int] $AmountOfWords = 3,

        [Parameter(Mandatory = $false, Position = 3, HelpMessage = 'Separator to use between words')]
        [ValidateNotNullOrEmpty()]
        [char] $Separator = ' ',

        [Parameter(Mandatory = $false, HelpMessage = 'Includes numbers in passphrase')]
        [switch] $IncludeNumbers,

        [Parameter(Mandatory = $false, Position = 1, HelpMessage = 'Amount of numbers to include in passphrase')]
        [ValidateNotNullOrEmpty()]
        [int] $AmountOfNumbers = 1,

        [Parameter(Mandatory = $false, HelpMessage = 'Include an uppercase word in passphrase')]
        [switch] $IncludeUppercase,

        [Parameter(Mandatory = $false, HelpMessage = 'Include special characters in passphrase')]
        [switch] $IncludeSpecials,

        [Parameter(Mandatory = $false, Position = 2, HelpMessage = 'Amount of special characters to include in passphrase')]
        [int] $AmountOfSpecials = 1,

        [Parameter(Mandatory = $false, HelpMessage = 'Return passphrase as object')]
        [switch] $AsObject,

        [Parameter(ParameterSetName = 'Custom', Mandatory = $true, ValueFromPipeline = $true, HelpMessage = 'Custom string to build passphrase object from')]
        [string] $CustomString
    )

    begin {
        $ErrorActionPreference = 'Stop'
        $InformationPreference = 'Continue'
        if (-not $PSBoundParameters.ContainsKey('Verbose')) { $VerbosePreference = $PSCmdlet.SessionState.PSVariable.GetValue('VerbosePreference') }
        if (-not $PSBoundParameters.ContainsKey('Confirm')) { $ConfirmPreference = $PSCmdlet.SessionState.PSVariable.GetValue('ConfirmPreference') }
        if (-not $PSBoundParameters.ContainsKey('WhatIf')) { $WhatIfPreference = $PSCmdlet.SessionState.PSVariable.GetValue('WhatIfPreference') }
        Write-Verbose ('[{0}] Confirm={1} ConfirmPreference={2} WhatIf={3} WhatIfPreference={4}' -f $MyInvocation.MyCommand, $Confirm, $ConfirmPreference, $WhatIf, $WhatIfPreference)
    } process {
        if ($PSCmdlet.ShouldProcess("Generates a new random passphrase as a string or object")) {
            try {
                if ($PSBoundParameters.ContainsKey('CustomString')) {
                    [PassphraseObject] $PassphraseObject = [PassphraseObject]::new($CustomString, $Separator)
                } else {
                    [string[]] $Words = Get-Content -Path ('{0}\..\private\Passphraser.Words.txt' -f $PSScriptroot)

                    [PassphraseObject] $PassphraseObject = [PassphraseObject]::new($Words, $AmountOfWords, $Separator)
                }

                if ($PSBoundParameters.ContainsKey('IncludeUppercase')) {
                    $PassphraseObject.AddUppercase()
                }

                if ($PSBoundParameters.ContainsKey('IncludeNumbers')) {
                    $PassphraseObject.AddNumber($AmountOfNumbers)
                }

                if ($PSBoundParameters.ContainsKey('IncludeSpecials')) {
                    $PassphraseObject.AddSpecial($AmountOfSpecials)
                }

                if ($PSBoundParameters.ContainsKey('AsObject')) {
                    return $PassphraseObject
                } else {
                    return $PassphraseObject.ToString()
                }
            } catch {
                $PSCmdlet.throwTerminatingError($PSItem)
            }
        }
    } end {}
}
