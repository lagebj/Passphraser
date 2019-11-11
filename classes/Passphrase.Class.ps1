﻿class Passphrase {
    [ValidateCount(
        0,
        3065)]
    [System.Collections.Generic.List[string]]$Words = @()

    [ValidateRange(
        0,
        9)]
    [System.Collections.Generic.List[int]]$Numbers = @()

    [ValidatePattern(
        '[!"#$%&()*+,./:;<=>?@\^_{|}]')]
    [System.Collections.Generic.List[char]]$Specials = @()

    [ValidateNotNullOrEmpty()]
    [char]$Separator

    [bool]$IncludeUppercase = $false

    [ValidateSet(
        'Weak',
        'Reasonable',
        'Strong',
        'Very strong',
        'Overkill')]
    [string]$Strength

    [ValidateRange(
        0,
        50128)]
    [double]$Points

    [int]$Length

    Passphrase(
        [string[]]$Words) {
        $Words | Get-Random -Count 3 | ForEach-Object {
            $this.Words.Add($_)
        }

        $this.Separator = ' '

        $PassphraseStrength = $this.GetStrength($true)
        $this.Points = $PassphraseStrength[0]
        $this.Strength = $PassphraseStrength[1]
        $this.Length = $this.ToString().Length
    }

    Passphrase(
        [string]$Passphrase,
        [char]$Separator) {
        [string[]]$WordsArray = $Passphrase.Split($Separator)

        [string[]]$WordsWithNumbers = $WordsArray -match '\d'
        [int[]]$NumbersFound = $WordsWithNumbers -replace '\D',''
        $NumbersFound | ForEach-Object {
            [int[]](($_ -split '') -ne '') | ForEach-Object {
                $this.Numbers.Add($_)
            }
        }
        $WordsWithNumbers | ForEach-Object {
            $WordsArray = $WordsArray.Replace($_, ($_ -replace '\d',''))
        }

        [string[]]$WordsWithSpecials = $WordsArray -match '[^A-Za-z0-9]+'
        [string[]]$SpecialsFound = $WordsWithSpecials -replace '[A-Za-z0-9]+'
        $SpecialsFound | ForEach-Object {
            [char[]](($_ -split '') -ne '') | ForEach-Object {
                $this.Specials.Add($_)
            }
        }
        $WordsWithSpecials | ForEach-Object {
            $WordsArray = $WordsArray.Replace($_, ($_ -replace '[^A-Za-z0-9]+',''))
        }

        [string[]]$WordsUppercase = $WordsArray -cmatch '[A-Z]+'
        $WordsUppercase | ForEach-Object {
            $WordsArray = $WordsArray.Replace($_, $_.ToLower())
        }
        if ($WordsUppercase) {
            $this.IncludeUppercase = $true
        }

        $WordsArray | ForEach-Object {
            $this.Words.Add($_)
        }

        $this.Separator = $Separator

        $PassphraseStrength = $this.GetStrength($true)
        $this.Points = $PassphraseStrength[0]
        $this.Strength = $PassphraseStrength[1]
        $this.Length = $this.ToString().Length
    }

    Passphrase(
        [string[]]$Words,
        [int]$AmountOfWords,
        [char]$Separator) {
        $Words | Get-Random -Count $AmountOfWords | ForEach-Object {
            $this.Words.Add($_)
        }

        $this.Separator = $Separator

        $PassphraseStrength = $this.GetStrength($true)
        $this.Points = $PassphraseStrength[0]
        $this.Strength = $PassphraseStrength[1]
        $this.Length = $this.ToString().Length
    }

    Passphrase(
        [string[]]$Words,
        [int]$AmountOfWords,
        [char]$Separator,
        [int]$AmountOfNumbers,
        [int]$AmountOfSpecials,
        [bool]$IncludeUppercase) {
        $Words | Get-Random -Count $AmountOfWords | ForEach-Object {
            $this.Words.Add($_)
        }

        $this.Separator = $Separator

        $this.AddNumber($AmountOfNumbers)

        $this.AddSpecial($AmountOfSpecials)

        if ($IncludeUppercase) {
            $this.AddUppercase()
        }

        $PassphraseStrength = $this.GetStrength($true)
        $this.Points = $PassphraseStrength[0]
        $this.Strength = $PassphraseStrength[1]
        $this.Length = $this.ToString().Length
    }

    [void]AddWord(
        [string[]]$Words) {
        $Words | ForEach-Object {
            $this.Words.Add($_)
        }

        $PassphraseStrength = $this.GetStrength($true)
        $this.Points = $PassphraseStrength[0]
        $this.Strength = $PassphraseStrength[1]
        $this.Length = $this.ToString().Length
    }

    [void]AddNumber(
        [int]$AmountOfNumbers) {
        for ($i = 1; $i -le $AmountOfNumbers; $i++) {
            [int]$Number = (0..9) | Get-Random
            $this.Numbers.Add($Number)
        }

        $PassphraseStrength = $this.GetStrength($true)
        $this.Points = $PassphraseStrength[0]
        $this.Strength = $PassphraseStrength[1]
        $this.Length = $this.ToString().Length
    }
    
    [void]AddSpecial(
        [int]$AmountOfSpecials) {
        [char[]]$SpecialCharacters = '!"#$%&()*+,./:;<=>?@\^_{|}'.ToCharArray()

        for ($i = 1; $i -le $AmountOfSpecials; $i++) {
            $Special = $SpecialCharacters | Get-Random
            $this.Specials.Add($Special)
        }

        $PassphraseStrength = $this.GetStrength($true)
        $this.Points = $PassphraseStrength[0]
        $this.Strength = $PassphraseStrength[1]
        $this.Length = $this.ToString().Length
    }

    [void]AddUppercase() {
        $this.IncludeUppercase = $true

        $PassphraseStrength = $this.GetStrength($true)
        $this.Points = $PassphraseStrength[0]
        $this.Strength = $PassphraseStrength[1]
        $this.Length = $this.ToString().Length
    }

    [void]RemoveWord(
        [string[]]$Words) {
        $Words | ForEach-Object {
            $this.Words.Remove($_)
        }

        $PassphraseStrength = $this.GetStrength($true)
        $this.Points = $PassphraseStrength[0]
        $this.Strength = $PassphraseStrength[1]
        $this.Length = $this.ToString().Length
    }

    [void]RemoveNumber(
        [int[]]$Numbers) {
        $Numbers | ForEach-Object {
            $this.Numbers.Remove($_)
        }

        $PassphraseStrength = $this.GetStrength($true)
        $this.Points = $PassphraseStrength[0]
        $this.Strength = $PassphraseStrength[1]
        $this.Length = $this.ToString().Length
    }

    [void]RemoveSpecial(
        [char[]]$Specials) {
        $Specials | ForEach-Object {
            $this.Specials.Remove($_)
        }

        $PassphraseStrength = $this.GetStrength($true)
        $this.Points = $PassphraseStrength[0]
        $this.Strength = $PassphraseStrength[1]
        $this.Length = $this.ToString().Length
    }

    [void]RemoveUppercase() {
        $this.IncludeUppercase = $false

        $PassphraseStrength = $this.GetStrength($true)
        $this.Points = $PassphraseStrength[0]
        $this.Strength = $PassphraseStrength[1]
        $this.Length = $this.ToString().Length
    }

    [string]GetStrength() {
        [string]$String = $this.ToString()
        [double]$Score = 0
        [int]$CharacterSets = 0
        [int]$MultipleCharactersInSets = 0

        if ($String.Length -ge 1) {
            $Score = $Score + 4
        }

        if ($String.Length -ge 8) {
            (($String.Substring(1, 7) -split '') -ne '') | ForEach-Object {
                $Score = $Score + 2
            }
        } elseif ($String.Length -lt 8 -and $String.Length -gt 1) {
            (($String.Substring(1, ($String.Length - 1)) -split '') -ne '') | ForEach-Object {
                $Score = $Score + 2
            }
        }

        if ($String.Length -le 20 -and $String.Length -gt 8) {
            (($String.Substring(8, ($String.Length - 8)) -split '') -ne '') | ForEach-Object {
                $Score = $Score + 1.5
            }
        }

        if ($String.Length -gt 20) {
            (($String.Substring(20, ($String.Length - 20)) -split '') -ne '') | ForEach-Object {
                $Score = $Score + 1
            }
        }

        switch -Regex -CaseSensitive ($String) {
            ([regex]::new('[a-z]')) {
                $CharacterSets++
            }
            ([regex]::new('[A-Z]')) {
                $CharacterSets++
            }
            ([regex]::new('\d')) {
                $CharacterSets++
            }
            ([regex]::new('[!"#$%&()*+,-./:;<=>?@\^_{|}]')) {
                $CharacterSets++
            }
            ([regex]::new('[a-z].*[a-z]')) {
                $MultipleCharactersInSets++
            }
            ([regex]::new('[A-Z].*[A-Z]')) {
                $MultipleCharactersInSets++
            }
            ([regex]::new('\d.*\d')) {
                $MultipleCharactersInSets++
            }
            ([regex]::new('[!"#$%&()*+,-./:;<=>?@\^_{|}].*[!"#$%&()*+,-./:;<=>?@\^_{|}]')) {
                $MultipleCharactersInSets++
            }
        }

        if ($MultipleCharactersInSets -ge 3) {
            $Score = $Score + 8
        } elseif ($CharacterSets -ge 3) {
            $Score = $Score + 6
        }

        $PassphraseStrength = switch ([int]$Score) {
            {0..27 -contains $_} {
                'Weak'
            }
            {28..35 -contains $_} {
                'Reasonable'
            }
            {36..59 -contains $_} {
                'Strong'
            }
            {60..127 -contains $_} {
                'Very strong'
            }
            {128..50128 -contains $_} {
                'Overkill'
            }
        }

        return $PassphraseStrength
    }

    [array]GetStrength(
        [bool]$IncludePoints) {
        [string]$String = $this.ToString()
        [double]$Score = 0
        [int]$CharacterSets = 0
        [int]$MultipleCharactersInSets = 0

        if ($String.Length -ge 1) {
            $Score = $Score + 4
        }

        if ($String.Length -ge 8) {
            (($String.Substring(1, 7) -split '') -ne '') | ForEach-Object {
                $Score = $Score + 2
            }
        } elseif ($String.Length -lt 8 -and $String.Length -gt 1) {
            (($String.Substring(1, ($String.Length - 1)) -split '') -ne '') | ForEach-Object {
                $Score = $Score + 2
            }
        }

        if ($String.Length -le 20 -and $String.Length -gt 8) {
            (($String.Substring(8, ($String.Length - 8)) -split '') -ne '') | ForEach-Object {
                $Score = $Score + 1.5
            }
        }

        if ($String.Length -gt 20) {
            (($String.Substring(20, ($String.Length - 20)) -split '') -ne '') | ForEach-Object {
                $Score = $Score + 1
            }
        }

        switch -Regex -CaseSensitive ($String) {
            ([regex]::new('[a-z]')) {
                $CharacterSets++
            }
            ([regex]::new('[A-Z]')) {
                $CharacterSets++
            }
            ([regex]::new('\d')) {
                $CharacterSets++
            }
            ([regex]::new('[!"#$%&()*+,-./:;<=>?@\^_{|}]')) {
                $CharacterSets++
            }
            ([regex]::new('[a-z].*[a-z]')) {
                $MultipleCharactersInSets++
            }
            ([regex]::new('[A-Z].*[A-Z]')) {
                $MultipleCharactersInSets++
            }
            ([regex]::new('\d.*\d')) {
                $MultipleCharactersInSets++
            }
            ([regex]::new('[!"#$%&()*+,-./:;<=>?@\^_{|}].*[!"#$%&()*+,-./:;<=>?@\^_{|}]')) {
                $MultipleCharactersInSets++
            }
        }

        if ($MultipleCharactersInSets -ge 3) {
            $Score = $Score + 8
        } elseif ($CharacterSets -ge 3) {
            $Score = $Score + 6
        }

        $PassphraseStrength = switch ([int]$Score) {
            {0..27 -contains $_} {
                'Weak'
            }
            {28..35 -contains $_} {
                'Reasonable'
            }
            {36..59 -contains $_} {
                'Strong'
            }
            {60..127 -contains $_} {
                'Very strong'
            }
            {128..50128 -contains $_} {
                'Overkill'
            }
        }

        if ($IncludePoints) {
            return $Score, $PassphraseStrength
        } else {
            return $PassphraseStrength
        }
    }

    [string]ToString() {
        [string[]]$WordsArray = $this.Words | Sort-Object {Get-Random}

        if ($this.IncludeUppercase) {
            [string]$Word = $WordsArray | Get-Random
            $WordsArray = $WordsArray.Replace($Word, $Word.ToUpper())
        }
        
        foreach ($Num in $this.Numbers) {
            [string]$Word = $WordsArray | Get-Random
            [int]$Placement = @(
                0,
                $Word.Length) | Get-Random
            [string]$WordWithNumber = $Word.Insert($Placement, $Num)
            $WordsArray = $WordsArray.Replace($Word, $WordWithNumber)
        }

        foreach ($Char in $this.Specials) {
            [string]$Word = $WordsArray | Get-Random
            [int]$Placement = @(
                0,
                $Word.Length) | Get-Random
            [string]$WordWithSpecial = $Word.Insert($Placement, $Char)
            $WordsArray = $WordsArray.Replace($Word, $WordWithSpecial)
        }

        return $WordsArray -join $this.Separator
    }
}