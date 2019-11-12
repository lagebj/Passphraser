class DateMatcher {
    [string]$DatePattern = 'date'

    [string]$DateWithSlashesSuffixPattern = [regex]::new(
        '(\d{1,2})(\s|-|/|\\|_|\.)(\d{1,2})\2(19\d{2}|200\d|201\d|\d{2})'
    )

    [string]$DateWithSlashesPrefixPattern = [regex]::new(
        '(19\d{2}|200\d|201\d|\d{2})(\s|-|/|\\|_|\.)(\d{1,2})\2(\d{1,2})'
    )

    [System.Collections.Generic.IEnumerable[System.Text.RegularExpressions.Match]]MatchPassword([string]$Password) {
        [System.Collections.Generic.List[System.Text.RegularExpressions.Match]]$Matches = @()
        [System.Text.RegularExpressions.MatchCollection]$PossibleDates = [regex]::Matches($Password, '\d{4,8}')
        foreach ($DateMatch in $PossibleDates) {
            if ($this.IsDate($DateMatch.Value)) {
                $Matches.Add(
                    [Match] {
                        Pattern = $this.DatePattern
                        i       = $DateMatch.Index
                        j       = $DateMatch.Index + $DateMatch.Length - 1
                        Token   = $DateMatch.Value
                        Entropy = $this.CalculateEntropy($DateMatch.Value, $null, $false)
                    }
                )
            }
        }
        return $PossibleDates
    }

    hidden [bool]IsDate([string]$Match) {
        $IsValid = $false

        if ($Match.Length -le 6) {
            $IsValid -bor $this.IsDateWithYearType($Match, $true, 2)
            $IsValid -bor $this.IsDateWithYearType($Match, $false, 2)
        } elseif ($Match.Length -ge 6) {
            $IsValid -bor $this.IsDateWithYearType($Match, $true, 4)
            $IsValid -bor $this.IsDateWithYearType($Match, $false, 4)
        }

        return $IsValid
    }
    
    hidden [bool]IsDateWithYearType([string]$Match, [bool]$Suffix, [int]$YearLength) {
        [int]$Year = 0
        if ($Suffix) {
            [System.Convert]::ToInt32($Match)
        }
    }
}