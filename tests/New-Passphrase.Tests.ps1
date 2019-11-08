. $PSScriptRoot\Shared.ps1

Describe 'New-Passphrase Tests' {
    Context 'Generates password with default settings, 3 all lowercase words, no numbers and whitespace (" ") as separator' {
        [string]$PasswordString = New-Passphrase
        It 'Contains 3 words' {
            $PasswordString.Split(" ") | Should -HaveCount 3
        }
        It 'Contains lowercase letters only' {
            $PasswordString | Should -MatchExactly $PasswordString.ToLower()
        }
        It 'Does not contain numbers' {
            $PasswordString | Should -Not -Match ([regex]::new('.*\d+.*'))
        }
        It 'Contains whitespace' {
            $PasswordString | Should -Match ([regex]::new('.*\s+.*'))
        }
    }

    Context 'Generates password with 4 all lowercase words, no numbers and dash ("-") as separator' {
        [string]$PasswordString = New-Passphrase -AmountOfWords 4 -Separator "-"
        It 'Contains 4 words' {
            $PasswordString.Split("-") | Should -HaveCount 4
        }
        It 'Contains lowercase letters only' {
            $PasswordString | Should -MatchExactly $PasswordString.ToLower()
        }
        It 'Does not contain numbers' {
            $PasswordString | Should -Not -Match ([regex]::new('.*\d+.*'))
        }
        It 'Contains dash' {
            $PasswordString | Should -Match ([regex]::new('.*-.*'))
        }
    }

    Context 'Generates password with 4 all lowercase words, 1 number and dash ("-") as separator' {
        [string]$PasswordString = New-Passphrase -AmountOfWords 4 -Separator "-" -IncludeNumbers
        It 'Contains 4 words' {
            $PasswordString.Split("-") | Should -HaveCount 4
        }
        It 'Contains lowercase letters only' {
            $PasswordString | Should -MatchExactly $PasswordString.ToLower()
        }
        It 'Contains number(s)' {
            $PasswordString | Should -Match ([regex]::new('.*\d+.*'))
        }
        It 'Contains dash' {
            $PasswordString | Should -Match ([regex]::new('.*-.*'))
        }
    }

    Context 'Generates password with 4 words, 2 numbers, dash ("-") as separator and one uppercase word' {
        [string]$PasswordString = New-Passphrase -AmountOfWords 4 -Separator "-" -IncludeNumbers -AmountOfNumbers 2 -IncludeUppercase
        It 'Contains 4 words' {
            $PasswordString.Split("-") | Should -HaveCount 4
        }
        It 'Contains lowercase letters' {
            $PasswordString | Should -Match ([regex]::new('[a-z]'))
        }
        It 'Contains uppercase letters' {
            $PasswordString | Should -Match ([regex]::new('[A-Z]'))
        }
        It 'Contains number(s)' {
            $PasswordString | Should -Match ([regex]::new('.*\d+.*'))
        }
        It 'Contains dash' {
            $PasswordString | Should -Match ([regex]::new('.*-.*'))
        }
    }

    Context 'Generates password with 4 words, 2 numbers, whitespace (" ") as separator, one uppercase word and 1 special character' {
        [string]$PasswordString = New-Passphrase -AmountOfWords 4 -IncludeNumbers -AmountOfNumbers 2 -IncludeUppercase -IncludeSpecials
        It 'Contains 4 words' {
            $PasswordString.Split(" ") | Should -HaveCount 4
        }
        It 'Contains lowercase letters' {
            $PasswordString | Should -Match ([regex]::new('[a-z]'))
        }
        It 'Contains uppercase letters' {
            $PasswordString | Should -Match ([regex]::new('[A-Z]'))
        }
        It 'Contains number(s)' {
            $PasswordString | Should -Match ([regex]::new('.*\d+.*'))
        }
        It 'Contains whitespace(s)' {
            $PasswordString | Should -Match ([regex]::new('.*\s+.*'))
        }
        It 'Contains special character(s)' {
            $PasswordString | Should -Match ([regex]::new('.[!"#$%&()*+,-./:;<=>?@\^_{|}].*'))
        }
    }
}