class PassphraseObject : Zxcvbn.Result {
    [ValidateCount(0, 3065)]
    [System.Collections.Generic.List[string]] $Words = @()

    [ValidateRange(0, 9)]
    [System.Collections.Generic.List[int]] $Numbers = @()

    [ValidatePattern('[!#%&()*+,./:;<=>@^_{|}]')]
    [System.Collections.Generic.List[char]] $Specials = @()

    [ValidateNotNullOrEmpty()]
    [char] $Separator

    [bool] $IncludeUppercase = $false

    [int] $Length

    PassphraseObject([string[]] $Words) {
        $Words | Get-Random -Count 3 | ForEach-Object {
            $this.Words.Add($PSItem)
        }

        [string] $PassphraseAsString = $this.ToString()

        $this.Separator = ' '
        $this.Length = $PassphraseAsString.Length

        $Zxcvbn = [Zxcvbn.Zxcvbn]::MatchPassword($PassphraseAsString)

        $this.Entropy = $Zxcvbn.Entropy
        $this.CalcTime = $Zxcvbn.CalcTime
        $this.CrackTime = $Zxcvbn.CrackTime
        $this.CrackTimeDisplay = $Zxcvbn.CrackTimeDisplay
        $this.Score = $Zxcvbn.Score
        $this.MatchSequence = $Zxcvbn.MatchSequence
        $this.Password = $Zxcvbn.Password
        $this.Warning = $Zxcvbn.warning
        $this.Suggestions = $Zxcvbn.suggestions
    }

    PassphraseObject([string] $Passphrase, [char] $Separator) {
        [string[]] $WordsArray = $Passphrase.Split($Separator)

        [string[]] $WordsWithNumbers = $WordsArray -match '\d'
        [int[]] $NumbersFound = $WordsWithNumbers -replace '\D', ''
        $NumbersFound | ForEach-Object {
            [int[]] (($PSItem -split '') -ne '') | ForEach-Object {
                $this.Numbers.Add($PSItem)
            }
        }
        $WordsWithNumbers | ForEach-Object {
            [string[]] $WordsArray = $WordsArray.Replace($PSItem, ($PSItem -replace '\d', ''))
        }

        [string[]] $WordsWithSpecials = $WordsArray -match '[^A-Za-z0-9]+'
        [string[]] $SpecialsFound = $WordsWithSpecials -replace '[A-Za-z0-9]+'
        $SpecialsFound | ForEach-Object {
            [char[]] (($PSItem -split '') -ne '') | ForEach-Object {
                $this.Specials.Add($PSItem)
            }
        }
        $WordsWithSpecials | ForEach-Object {
            [string[]] $WordsArray = $WordsArray.Replace($PSItem, ($PSItem -replace '[^A-Za-z0-9]+', ''))
        }

        [string[]] $WordsUppercase = $WordsArray -cmatch '[A-Z]+'
        $WordsUppercase | ForEach-Object {
            [string[]] $WordsArray = $WordsArray.Replace($PSItem, $PSItem.ToLower())
        }
        
        if ($WordsUppercase) {
            $this.IncludeUppercase = $true
        }

        $WordsArray | ForEach-Object {
            $this.Words.Add($PSItem)
        }

        [string] $PassphraseAsString = $this.ToString()

        $this.Separator = $Separator
        $this.Length = $PassphraseAsString.Length

        $Zxcvbn = [Zxcvbn.Zxcvbn]::MatchPassword($PassphraseAsString)

        $this.Entropy = $Zxcvbn.Entropy
        $this.CalcTime = $Zxcvbn.CalcTime
        $this.CrackTime = $Zxcvbn.CrackTime
        $this.CrackTimeDisplay = $Zxcvbn.CrackTimeDisplay
        $this.Score = $Zxcvbn.Score
        $this.MatchSequence = $Zxcvbn.MatchSequence
        $this.Password = $Zxcvbn.Password
        $this.Warning = $Zxcvbn.warning
        $this.Suggestions = $Zxcvbn.suggestions
    }

    PassphraseObject([string[]] $Words, [int] $AmountOfWords, [char] $Separator) {
        $Words | Get-Random -Count $AmountOfWords | ForEach-Object {
            $this.Words.Add($PSItem)
        }

        [string] $PassphraseAsString = $this.ToString()

        $this.Separator = $Separator
        $this.Length = $PassphraseAsString.Length

        $Zxcvbn = [Zxcvbn.Zxcvbn]::MatchPassword($PassphraseAsString)

        $this.Entropy = $Zxcvbn.Entropy
        $this.CalcTime = $Zxcvbn.CalcTime
        $this.CrackTime = $Zxcvbn.CrackTime
        $this.CrackTimeDisplay = $Zxcvbn.CrackTimeDisplay
        $this.Score = $Zxcvbn.Score
        $this.MatchSequence = $Zxcvbn.MatchSequence
        $this.Password = $Zxcvbn.Password
        $this.Warning = $Zxcvbn.warning
        $this.Suggestions = $Zxcvbn.suggestions
    }

    PassphraseObject([string[]] $Words, [int] $AmountOfWords, [char] $Separator, [int] $AmountOfNumbers, [int] $AmountOfSpecials, [bool] $IncludeUppercase) {
        $Words | Get-Random -Count $AmountOfWords | ForEach-Object {
            $this.Words.Add($PSItem)
        }

        $this.AddNumber($AmountOfNumbers)
        $this.AddSpecial($AmountOfSpecials)

        if ($IncludeUppercase) {
            $this.AddUppercase()
        }

        [string] $PassphraseAsString = $this.ToString()

        $this.Separator = $Separator
        $this.Length = $PassphraseAsString.Length

        $Zxcvbn = [Zxcvbn.Zxcvbn]::MatchPassword($PassphraseAsString)

        $this.Entropy = $Zxcvbn.Entropy
        $this.CalcTime = $Zxcvbn.CalcTime
        $this.CrackTime = $Zxcvbn.CrackTime
        $this.CrackTimeDisplay = $Zxcvbn.CrackTimeDisplay
        $this.Score = $Zxcvbn.Score
        $this.MatchSequence = $Zxcvbn.MatchSequence
        $this.Password = $Zxcvbn.Password
        $this.Warning = $Zxcvbn.warning
        $this.Suggestions = $Zxcvbn.suggestions
    }

    [void] AddWord([string[]] $Words) {
        $Words | ForEach-Object {
            $this.Words.Add($PSItem)
        }

        [string] $PassphraseAsString = $this.ToString()

        $this.Length = $PassphraseAsString.Length

        $Zxcvbn = [Zxcvbn.Zxcvbn]::MatchPassword($PassphraseAsString)

        $this.Entropy = $Zxcvbn.Entropy
        $this.CalcTime = $Zxcvbn.CalcTime
        $this.CrackTime = $Zxcvbn.CrackTime
        $this.CrackTimeDisplay = $Zxcvbn.CrackTimeDisplay
        $this.Score = $Zxcvbn.Score
        $this.MatchSequence = $Zxcvbn.MatchSequence
        $this.Password = $Zxcvbn.Password
        $this.Warning = $Zxcvbn.warning
        $this.Suggestions = $Zxcvbn.suggestions
    }

    [void] AddNumber([int] $AmountOfNumbers) {
        for ($i = 1; $i -le $AmountOfNumbers; $i++) {
            [int]$Number = (0..9) | Get-Random
            $this.Numbers.Add($Number)
        }

        [string] $PassphraseAsString = $this.ToString()

        $this.Length = $PassphraseAsString.Length

        $Zxcvbn = [Zxcvbn.Zxcvbn]::MatchPassword($PassphraseAsString)

        $this.Entropy = $Zxcvbn.Entropy
        $this.CalcTime = $Zxcvbn.CalcTime
        $this.CrackTime = $Zxcvbn.CrackTime
        $this.CrackTimeDisplay = $Zxcvbn.CrackTimeDisplay
        $this.Score = $Zxcvbn.Score
        $this.MatchSequence = $Zxcvbn.MatchSequence
        $this.Password = $Zxcvbn.Password
        $this.Warning = $Zxcvbn.warning
        $this.Suggestions = $Zxcvbn.suggestions
    }
    
    [void] AddSpecial([int] $AmountOfSpecials) {
        [char[]] $SpecialCharacters = '!#%&()*+,./:;<=>@^_{|}'.ToCharArray()

        for ($i = 1; $i -le $AmountOfSpecials; $i++) {
            [char] $Special = $SpecialCharacters | Get-Random

            $this.Specials.Add($Special)
        }

        [string] $PassphraseAsString = $this.ToString()

        $this.Length = $PassphraseAsString.Length

        $Zxcvbn = [Zxcvbn.Zxcvbn]::MatchPassword($PassphraseAsString)

        $this.Entropy = $Zxcvbn.Entropy
        $this.CalcTime = $Zxcvbn.CalcTime
        $this.CrackTime = $Zxcvbn.CrackTime
        $this.CrackTimeDisplay = $Zxcvbn.CrackTimeDisplay
        $this.Score = $Zxcvbn.Score
        $this.MatchSequence = $Zxcvbn.MatchSequence
        $this.Password = $Zxcvbn.Password
        $this.Warning = $Zxcvbn.warning
        $this.Suggestions = $Zxcvbn.suggestions
    }

    [void] AddUppercase() {
        $this.IncludeUppercase = $true

        [string] $PassphraseAsString = $this.ToString()

        $this.Length = $PassphraseAsString.Length

        $Zxcvbn = [Zxcvbn.Zxcvbn]::MatchPassword($PassphraseAsString)

        $this.Entropy = $Zxcvbn.Entropy
        $this.CalcTime = $Zxcvbn.CalcTime
        $this.CrackTime = $Zxcvbn.CrackTime
        $this.CrackTimeDisplay = $Zxcvbn.CrackTimeDisplay
        $this.Score = $Zxcvbn.Score
        $this.MatchSequence = $Zxcvbn.MatchSequence
        $this.Password = $Zxcvbn.Password
        $this.Warning = $Zxcvbn.warning
        $this.Suggestions = $Zxcvbn.suggestions
    }

    [void] RemoveWord([string[]] $Words) {
        $Words | ForEach-Object {
            $this.Words.Remove($PSItem)
        }

        [string] $PassphraseAsString = $this.ToString()

        $this.Length = $PassphraseAsString.Length

        $Zxcvbn = [Zxcvbn.Zxcvbn]::MatchPassword($PassphraseAsString)

        $this.Entropy = $Zxcvbn.Entropy
        $this.CalcTime = $Zxcvbn.CalcTime
        $this.CrackTime = $Zxcvbn.CrackTime
        $this.CrackTimeDisplay = $Zxcvbn.CrackTimeDisplay
        $this.Score = $Zxcvbn.Score
        $this.MatchSequence = $Zxcvbn.MatchSequence
        $this.Password = $Zxcvbn.Password
        $this.Warning = $Zxcvbn.warning
        $this.Suggestions = $Zxcvbn.suggestions
    }

    [void] RemoveNumber([int[]] $Numbers) {
        $Numbers | ForEach-Object {
            $this.Numbers.Remove($PSItem)
        }

        [string] $PassphraseAsString = $this.ToString()

        $this.Length = $PassphraseAsString.Length

        $Zxcvbn = [Zxcvbn.Zxcvbn]::MatchPassword($PassphraseAsString)

        $this.Entropy = $Zxcvbn.Entropy
        $this.CalcTime = $Zxcvbn.CalcTime
        $this.CrackTime = $Zxcvbn.CrackTime
        $this.CrackTimeDisplay = $Zxcvbn.CrackTimeDisplay
        $this.Score = $Zxcvbn.Score
        $this.MatchSequence = $Zxcvbn.MatchSequence
        $this.Password = $Zxcvbn.Password
        $this.Warning = $Zxcvbn.warning
        $this.Suggestions = $Zxcvbn.suggestions
    }

    [void] RemoveSpecial([char[]] $Specials) {
        $Specials | ForEach-Object {
            $this.Specials.Remove($PSItem)
        }

        [string] $PassphraseAsString = $this.ToString()

        $this.Length = $PassphraseAsString.Length

        $Zxcvbn = [Zxcvbn.Zxcvbn]::MatchPassword($PassphraseAsString)

        $this.Entropy = $Zxcvbn.Entropy
        $this.CalcTime = $Zxcvbn.CalcTime
        $this.CrackTime = $Zxcvbn.CrackTime
        $this.CrackTimeDisplay = $Zxcvbn.CrackTimeDisplay
        $this.Score = $Zxcvbn.Score
        $this.MatchSequence = $Zxcvbn.MatchSequence
        $this.Password = $Zxcvbn.Password
        $this.Warning = $Zxcvbn.warning
        $this.Suggestions = $Zxcvbn.suggestions
    }

    [void] RemoveUppercase() {
        $this.IncludeUppercase = $false

        [string] $PassphraseAsString = $this.ToString()

        $this.Length = $PassphraseAsString.Length

        $Zxcvbn = [Zxcvbn.Zxcvbn]::MatchPassword($PassphraseAsString)

        $this.Entropy = $Zxcvbn.Entropy
        $this.CalcTime = $Zxcvbn.CalcTime
        $this.CrackTime = $Zxcvbn.CrackTime
        $this.CrackTimeDisplay = $Zxcvbn.CrackTimeDisplay
        $this.Score = $Zxcvbn.Score
        $this.MatchSequence = $Zxcvbn.MatchSequence
        $this.Password = $Zxcvbn.Password
        $this.Warning = $Zxcvbn.warning
        $this.Suggestions = $Zxcvbn.suggestions
    }

    [string] ToString() {
        [string[]] $WordsArray = $this.Words | Sort-Object {Get-Random}

        if ($this.IncludeUppercase) {
            [string] $Word = $WordsArray | Get-Random

            [string[]] $WordsArray = $WordsArray.Replace($Word, $Word.ToUpper())
        }
        
        foreach ($Num in $this.Numbers) {
            [string] $Word = $WordsArray | Get-Random

            [int] $Placement = @(0, $Word.Length) | Get-Random

            [string] $WordWithNumber = $Word.Insert($Placement, $Num)

            [string[]] $WordsArray = $WordsArray.Replace($Word, $WordWithNumber)
        }

        foreach ($Char in $this.Specials) {
            [string] $Word = $WordsArray | Get-Random

            [int] $Placement = @(0, $Word.Length) | Get-Random

            [string] $WordWithSpecial = $Word.Insert($Placement, $Char)

            [string[]] $WordsArray = $WordsArray.Replace($Word, $WordWithSpecial)
        }

        return ($WordsArray -join $this.Separator)
    }
}
