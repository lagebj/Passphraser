class PasswordScoring {
    [string] $StartUpper = '^[A-Z][^A-Z]+$'
    [string] $EndUpper = '^[^A-Z]+[A-Z]$'
    [string] $AllUpper = '^[^a-z]+$'
    [string] $AllLower = '^[^A-Z]+$'

    static [int] PasswordCardinality([string] $Password) {
        $cl = 0

        switch -Regex -CaseSensitive ($Password) {
            ([regex]::new('[a-z]')) {
                $cl += 26
            }
            ([regex]::new('[A-Z]')) {
                $cl += 26
            }
            ([regex]::new('\d')) {
                $cl += 10
            }
        }

        $PasswordArray = $Password.Split('').ToCharArray()
        
        foreach ($Char in $PasswordArray) {
            if (($Char -le '/') -or 
                (':' -le $Char -and $Char -le '@') -or 
                ('[' -le $Char -and $Char -le '`') -or 
                ('{' -le $Char -and $Char -le [char]127)) {
                    $cl += 33
                    continue
            }
        }
        foreach ($Char in $PasswordArray) {
            if ($Char -gt [char]127) {
                $cl += 100
                continue
            }
        }
        
        return $cl
    }

    static [double] EntropyToCrackTime([double] $Entropy) {
        [double] $SingleGuess = 0.01
        [double] $NumAttackers = 100
        [double] $SecondsPerGuess = $SingleGuess / $NumAttackers

        return 0.5 * [System.Math]::Pow(2, $Entropy) * $SecondsPerGuess
    }

    static [int] CrackTimeToScore([double] $CrackTimeSeconds) {
        if ($CrackTimeSeconds -lt [System.Math]::Pow(10, 2)) {
            return 0
        } elseif ($CrackTimeSeconds -lt [System.Math]::Pow(10, 4)) {
            return 1
        } elseif ($CrackTimeSeconds -lt [System.Math]::Pow(10, 6)) {
            return 2
        } elseif ($CrackTimeSeconds -lt [System.Math]::Pow(10, 8)) {
            return 3
        } else {
            return 4
        }
    }

    static [long] Binomial([int] $n, [int] $k) {
        if ($k -gt $n) {
            return 0
        }
        if ($k -eq 0) {
            return 1
        }

        [long] $r = 1
        for ([int] $d = 1; $d -le $k; $d++) {
            $r *= $n
            $r /= $d
            $n -= 1
        }

        return $r
    }

    static [double] CalculateUppercaseEntropy([string] $Word) {
        if ([Regex]::IsMatch($Word, [PasswordScoring]::new().AllLower)) {
            return 0
        }

        if ([Regex]::IsMatch($Word, [PasswordScoring]::new().StartUpper) -or [Regex]::IsMatch($Word, [PasswordScoring]::new().EndUpper) -or [Regex]::IsMatch($Word, [PasswordScoring]::new().AllUpper)) {
            return 1
        }

        $WordArray = $Word.Split('').ToCharArray()
        $Lowers = ($WordArray -cmatch '[a-z]').Count
        $Uppers = ($WordArray -cmatch '[A-Z]').Count

        $Sum = [System.Linq.Enumerable]::Sum([System.Linq.Enumerable]::Range(0, [System.Math]::Min($Uppers, $Lowers) + 1))
        return [System.Math]::Log([PasswordScoring]::Binomial($Uppers + $Lowers, $Sum), 2)
    }
}