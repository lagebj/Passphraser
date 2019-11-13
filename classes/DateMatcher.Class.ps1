class DateMatcher {
    [string]$DatePattern = 'date'

    [string]$DateWithSlashesSuffixPattern = [regex]::new(
        '(\d{1,2})(\s|-|/|\\|_|\.)(\d{1,2})\2(19\d{2}|200\d|201\d|\d{2})'
    )

    [string]$DateWithSlashesPrefixPattern = [regex]::new(
        '(19\d{2}|200\d|201\d|\d{2})(\s|-|/|\\|_|\.)(\d{1,2})\2(\d{1,2})'
    )

    [System.Collections.Generic.IEnumerable[Match]]MatchPassword([string]$Password) {
        [System.Collections.Generic.List[Match]]$Matches = @()

        [System.Text.RegularExpressions.MatchCollection]$PossibleDates = [regex]::Matches($Password, '\d{4,8}')
        foreach ($DateMatch in $PossibleDates) {
            if ($this.IsDate($DateMatch.Value)) {
                $Match = [Match]::new()
                $Match.Pattern = $this.DatePattern
                $Match.i = $DateMatch.Index
                $Match.j = $DateMatch.Index + $DateMatch.Length - 1
                $Match.Token = $DateMatch.Value
                $Match.Entropy = $this.CalculateEntropy($DateMatch.Value, $null, $false)
                $Matches.Add($Match)
            }
        }

        [System.Text.RegularExpressions.MatchCollection]$SlashDatesSuffix = [regex]::Matches($Password, $this.DateWithSlashesSuffixPattern, [System.Text.RegularExpressions.RegexOptions]::IgnorePatternWhitespace)
        foreach ($DateMatch in $SlashDatesSuffix) {
            [int]$Year = $DateMatch.Groups[4].Value
            [int]$Month = $DateMatch.Groups[3].Value
            [int]$Day = $DateMatch.Groups[1].Value

            if (12 -le $Month -and $Month -le 31 -and $Day -le 12) {
                [int]$T = $Month
                [int]$Month = $Day
                [int]$Day = $T
            }

            if ($this.IsDateInRange($Year, $Month, $Day)) {
                $Match = [Match]::new()
                $Match.Pattern = $this.DatePattern
                $Match.i = $DateMatch.Index
                $Match.j = $DateMatch.Index + $DateMatch.Length - 1
                $Match.Token = $DateMatch.Value
                $Match.Entropy = $this.CalculateEntropy($DateMatch.Value, $Year, $true)
                $Match.Separator = $DateMatch.Groups[2].Value
                $Match.Year  = $Year
                $Match.Month = $Month
                $Match.Day = $Day
                $Matches.Add($Match)
            }
        }

        [System.Text.RegularExpressions.MatchCollection]$SlashDatesPrefix = [regex]::Matches($Password, $this.DateWithSlashesPrefixPattern, [System.Text.RegularExpressions.RegexOptions]::IgnorePatternWhitespace)
        foreach ($DateMatch in $SlashDatesPrefix) {
            [int]$Year = $DateMatch.Groups[1].Value
            [int]$Month = $DateMatch.Groups[3].Value
            [int]$Day = $DateMatch.Groups[4].Value

            if (12 -le $Month -and $Month -le 31 -and $Day -le 12) {
                [int]$T = $Month
                [int]$Month = $Day
                [int]$Day = $T
            }

            if ($this.IsDateInRange($Year, $Month, $Day)) {
                $Match = [Match]::new()
                $Match.Pattern = $this.DatePattern
                $Match.i = $DateMatch.Index
                $Match.j = $DateMatch.Index + $DateMatch.Length - 1
                $Match.Token = $DateMatch.Value
                $Match.Entropy = $this.CalculateEntropy($DateMatch.Value, $Year, $true)
                $Match.Separator = $DateMatch.Groups[2].Value
                $Match.Year = $Year
                $Match.Month = $Month
                $Match.Day = $Day
                $Matches.Add($Match)
            }
        }
        return $Matches
    }

    hidden [double] CalculateEntropy([string]$Match, [System.Nullable[int]]$Year, [bool]$Separator) {
        if ($null -ne $Year) {
            if ($Match.Length -le 6) {
                $Year = 99
            } else {
                $Year = 9999
            }
        }
        [double]$Entropy = 0
        if ($Year -lt 100) {
            $Entropy = [System.Math]::Log(31 * 12 * 100, 2)
        } else {
            $Entropy = [System.Math]::Log(31 * 12 * 119, 2)
        }

        if ($Separator) {
            $Entropy = $Entropy + 2
        }
        return $Entropy
    }

    hidden [bool] IsDate([string]$Match) {
        [bool]$IsValid = $false

        if ($Match.Length -le 6) {
            $IsValid -bor $this.IsDateWithYearType($Match, $true, 2)
            $IsValid -bor $this.IsDateWithYearType($Match, $false, 2)
        } elseif ($Match.Length -ge 6) {
            $IsValid -bor $this.IsDateWithYearType($Match, $true, 4)
            $IsValid -bor $this.IsDateWithYearType($Match, $false, 4)
        }

        return $IsValid
    }
    
    hidden [bool] IsDateWithYearType([string]$Match, [bool]$Suffix, [int]$YearLength) {
        [int]$Year = 0
        if ($Suffix) {
            [Utility]::IntParseSubstring($Match, ($Match.Length - $YearLength), $YearLength, [ref]$Year)
        } else {
            [Utility]::IntParseSubstring($Match, 0, $YearLength, [ref]$Year)
        }

        if ($Suffix) {
            if ($this.IsYearInRange($Year) -and $this.IsDayMonthString($Match.Substring(0, $Match.Length - $YearLength))) {
                return $true
            } else {
                return $false
            }
        } else {
            if ($this.IsYearInRange($Year) -and $this.IsDayMonthString($Match.Substring($YearLength, $Match.Length - $YearLength))) {
                return $true
            } else {
                return $false
            }
        }
    }

    hidden [bool] IsDayMonthString([string]$Match) {
        [int]$p1 = 0
        [int]$p2 = 0
            
        if ($Match.Length -eq 2) {
            [Utility]::IntParseSubstring($Match, 0, 1, [ref]$p1)
            [Utility]::IntParseSubstring($Match, 1, 1, [ref]$p2)
        } elseif ($Match.Length -eq 3) {
            [Utility]::IntParseSubstring($Match, 0, 1, [ref]$p1)
            [Utility]::IntParseSubstring($Match, 1, 2, [ref]$p2)

            if ($this.IsMonthDayInRange($p1, $p2) -or $this.IsMonthDayInRange($p2, $p1)) {
                return $true
            }

            [Utility]::IntParseSubstring($Match, 0, 2, [ref]$p1)
            [Utility]::IntParseSubstring($Match, 2, 1, [ref]$p2)
        } elseif ($Match.Length -eq 4) {
            [Utility]::IntParseSubstring($Match, 0, 2, [ref]$p1)
            [Utility]::IntParseSubstring($Match, 2, 2, [ref]$p2)
        }

        if ($this.IsMonthDayInRange($p1, $p2) -or $this.IsMonthDayInRange($p2, $p1)) {
            return $true
        } else {
            return $false
        }
    }

    hidden [bool] IsDateInRange([int]$Year, [int]$Month, [int]$Day) {
        if ($this.IsYearInRange($Year) -and $this.IsMonthDayInRange($Month, $Day)) {
            return $true
        } else {
            return $false
        }
    }

    hidden [bool] IsYearInRange([int]$Year) {
        if ((1900 -le $Year -and $Year -le 2019) -or (0 -lt $Year -and $Year -le 99)) {
            return $true
        } else {
            return $false
        }
    }
    
    hidden [bool] IsMonthDayInRange([int]$Month, [int]$Day) {
        if (1 -le $Month -and $Month -le 12 -and 1 -le $Day -and $Day -le 31) {
            return $true
        } else {
            return $false
        }
    }
}