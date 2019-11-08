class Passphrase {
    [ValidateCount(0, 3065)][System.Collections.Generic.List[string]]$Words = @()
    [ValidateRange(0, 9)][System.Collections.Generic.List[int]]$Numbers = @()
    [ValidatePattern('[!"#$%&()*+,-./:;<=>?@\^_{|}]')][System.Collections.Generic.List[char]]$Specials = @()
    [AllowEmptyString()][string]$Separator

    Passphrase([array]$Words, [int]$AmountOfWords, [string]$Separator) {
        $Words | Get-Random -Count $AmountOfWords | ForEach-Object {
            $this.Words.Add($_)
        }
        $this.Separator = $Separator
    }

    [void]AddNumber([int]$AmountOfNumbers) {
        for ($i = 1; $i -le $AmountOfNumbers; $i++) {
            [int]$Number = (0..9) | Get-Random
            $this.Numbers.Add($Number)
        }
    }
    
    [void]AddSpecial([int]$AmountOfSpecials) {
        [char[]]$SpecialCharacters = '!"#$%&()*+,-./:;<=>?@\^_{|}' |
        ForEach-Object {
            [char[]]$_
        }
        for ($i = 1; $i -le $AmountOfSpecials; $i++) {
            $Special = $SpecialCharacters | Get-Random
            $this.Specials.Add($Special)
        }
    }

    [void]AddUppercase() {
        $Word = $this.Words | Get-Random
        $this.Words = $this.Words.Replace($Word, $Word.ToUpper())
    }

    [string]ToString() {
        foreach ($Num in $this.Numbers) {
            [string]$Word = $this.Words | Get-Random
            [int]$Placement = @(
                0,
                $Word.Length) | Get-Random
            [string]$WordWithNumber = $Word.Insert($Placement, $Num)
            $this.Words = $this.Words.Replace($Word, $WordWithNumber)
        }

        foreach ($Char in $this.Specials) {
            [string]$Word = $this.Words | Get-Random
            [int]$Placement = @(
                0,
                $Word.Length) | Get-Random
            [string]$WordWithSpecial = $Word.Insert($Placement, $Char)
            $this.Words = $this.Words.Replace($Word, $WordWithSpecial)
        }

        return $this.Words -join $this.Separator
    }
}