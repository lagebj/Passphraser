class Zxcvbn {
    hidden [string] $BruteforcePattern = 'bruteforce'
    hidden [IMatcherFactory] $MatcherFactory
    hidden [Translation] $Translation

    Zxcvbn([Translation] $Translation = [Translation]::English) : base([DefaultMatcherFactory]::new()) {
        $this.Translation = $Translation
    }

    Zxcvbn([IMatcherFactory] $MatcherFactory, [Translation] $Translation = [Translation]::English) {
        $this.MatcherFactory = $MatcherFactory
        $this.Translation = $Translation
    }

    [Result]EvaluatePassword([string] $Password, [System.Collections.Generic.IEnumerable[string]] $UserInputs = $null) {
        if (-not $UserInputs) {
            $UserInputs = [string]::new(0)
        }

        [System.Collections.Generic.IEnumerable[Match]] $Matches = [System.Collections.Generic.List[Match]]::new()
        
        $Timer = [System.Diagnostics.Stopwatch]::StartNew()
        
        foreach ($Matcher in $this.MatcherFactory.CreateMatchers($UserInputs)) {
            $Matches = $Matches.Union($Matcher.MatchPassword($Password))
        }

        $Result = $this.FindMinimumEntropyMatch($Password, $Matches)

        $Timer.Stop()
        $Result.CalcTime = $Timer.ElapsedMilliseconds

        return $Result
    }

    hidden [Result] FindMinimumEntropyMatch([string] $Password, [System.Collections.Generic.IEnumerable[Match]] $Matches) {
        $bruteforce_cardinality = [PasswordScoring]::PasswordCardinality($Password)

        $MinimumEntropyToIndex = [double]::new($Password.Length)
        $BestMatchForIndex = [Match]::new()[$Password.Length]

        for ($k = 0; $k -lt $Password.Length; $k++) {
            $MinimumEntropyToIndex[$k] = (
                if ($k -eq 0) {
                    0
                } else {
                    $MinimumEntropyToIndex[$k - 1]
                }) + [System.Math]::Log($bruteforce_cardinality, 2)

            foreach ($Match in $Matches | Where-Object { $_.j -eq $k }) {
                $candidate_entropy = (
                    if ($Match.i -le 0) {
                        0
                    } else {
                        $MinimumEntropyToIndex[$Match.i - 1]
                    }) + $Match.Entropy
                if ($candidate_entropy -lt $MinimumEntropyToIndex[$k]) {
                    $MinimumEntropyToIndex[$k] = $candidate_entropy
                    $BestMatchForIndex[$k] = $Match
                }
            }
        }

        [System.Collections.Generic.List[Match]] $MatchSequence = @()
        for ($k = $Password.Length - 1; $k -ge 0; $k--) {
            if ($null -ne $BestMatchForIndex[$k]) {
                $MatchSequence.Add($BestMatchForIndex[$k])
                $k = $BestMatchForIndex[$k].i
            }
        }

        $MatchSequence.Reverse()

        if ($MatchSequence.Count -eq 0) {
            $matchSequence.Add([Match]@{
                i = 0
                j = $Password.Length
                Token = $Password
                Cardinality = $bruteforce_cardinality
                Pattern = $this.BruteforcePattern
                Entropy = [System.Math]::Log([System.Math]::Pow($bruteforce_cardinality, $Password.Length), 2)
            })
        } else {
            [System.Collections.Generic.List[Match]] $MatchSequenceCopy = @()
            for ($k = 0; $k -lt $MatchSequence.Count; $k++) {
                $m1 = $MatchSequence[$k]
                $m2 = (
                    if ($k -lt ($MatchSequence.Count - 1)) {
                        $MatchSequence[$k + 1]
                    } else {
                        [Match]@{
                            i = $Password.Length
                        }
                    })

                $MatchSequenceCopy.Add($m1)
                if ($m1.j -lt ($m2.i - 1)) {
                    $ns = $m1.j + 1
                    $ne = $m2.i - 1
                    $MatchSequenceCopy.Add(
                        [Match]@{
                            i = $ns
                            j = $ne
                            Token = $Password.Substring($ns, ($ne - $ns + 1))
                            Cardinality = $bruteforce_cardinality
                            Pattern = $this.BruteforcePattern
                            Entropy = [System.Math]::Log([System.Math]::Pow($bruteforce_cardinality, ($ne - $ns + 1)), 2)
                        })
                }
            }

            $MatchSequence = $MatchSequenceCopy
        }

        $MinEntropy = (
            if ($Password.Length -eq 0) {
                0
            } else {
                $MinimumEntropyToIndex[$Password.Length - 1]
            })
        $CrackTime = [PasswordScoring]::EntropyToCrackTime($MinEntropy)

        $Result = [Result]::new()
        $Result.Password = $Password
        $Result.Entropy = [System.Math]::Round($MinEntropy, 3)
        $Result.MatchSequence = $MatchSequence
        $Result.CrackTime = [System.Math]::Round($CrackTime, 3)
        $Result.CrackTimeDisplay = [Utility]::DisplayTime($CrackTime, $this.Translation)
        $Result.Score = [PasswordScoring]::CrackTimeToScore($CrackTime)

        if ($null -eq $MatchSequence -or $MatchSequence.Count -eq 0) {
            $Result.Warning = [Warning]::Default
            $Result.Suggestions.Clear()
            $Result.Suggestions.Add([Suggestion]::Default)
        } else {
            if ($Result.Score -gt 2) {
                $Result.Warning = [Warning]::Empty
                $Result.Suggestions.Clear()
                $Result.Suggestions.Add([Suggestion]::Empty)
            } else {
                [Match] $LongestMatch = $this.GetLongestMatch($MatchSequence)
                $this.GetMatchFeedback($LongestMatch, $MatchSequence.Count -eq 1, $Result)
                $Result.Suggestions.Insert(0,[Suggestion]::AddAnotherWordOrTwo)
            }

        }

        return $Result
    }

    hidden [Match] GetLongestMatch([System.Collections.Generic.List[Match]] $MatchSequence) {
        [Match] $LongestMatch

        if ($null -ne $MatchSequence -and $MatchSequence.Count -gt 0) {
            $LongestMatch = $MatchSequence[0]
            foreach ($Match in $MatchSequence) {
                if ($Match.Token.Length -gt $LongestMatch.Token.Length) {
                    $LongestMatch = $Match
                }
            }
        } else {
            $LongestMatch = [Match]::new()
        }

        return $LongestMatch
    }

    hidden [void] GetMatchFeedback([Match] $Match, [bool] $IsSoleMatch, [Result] $Result)
    {
        switch ($Match.Pattern)
        {
            'dictionary' {
                $this.GetDictionaryMatchFeedback([DictionaryMatch] $Match, $IsSoleMatch, $Result)
                break
            }

            'spatial' {
                [SpatialMatch] $SpatialMatch = [SpatialMatch] $Match

                if ($SpatialMatch.Turns -eq 1) {
                    $Result.Warning = [Warning]::StraightRow
                } else {
                    $Result.Warning = [Warning]::ShortKeyboardPatterns
                }

                $Result.Suggestions.Clear()
                $Result.Suggestions.Add([Suggestion]::UseLongerKeyboardPattern)
                break
            }

            'repeat' {
                # todo: add support for repeated sequences longer than 1 char
                # if(match.Token.Length == 1)
                #     result.warning = Warning.RepeatsLikeAaaEasy;
                # else
                #    result.warning = Warning.RepeatsLikeAbcSlighterHarder;

                $Result.Suggestions.Clear()
                $Result.Suggestions.Add([Suggestion]::AvoidRepeatedWordsAndChars)
                break
            }

            'sequence' {
                $Result.Warning = [Warning]::SequenceAbcEasy

                $Result.Suggestions.Clear()
                $Result.Suggestions.Add([Suggestion]::AvoidSequences)
                break
            }

            # //todo: add support for recent_year, however not example exist on https://dl.dropboxusercontent.com/u/209/zxcvbn/test/index.html

            'date' {
                $Result.Warning = [Warning]::DatesEasy

                $Result.Suggestions.Clear()
                $Result.Suggestions.Add([Suggestion]::AvoidDatesYearsAssociatedYou)
                break
            }
        }
    }

    hidden [void] GetDictionaryMatchFeedback([DictionaryMatch] $Match, [bool] $IsSoleMatch, [Result] $Result) {
        if ($Match.DictionaryName.Equals('passwords')) {
            # todo: add support for reversed words
            if ($IsSoleMatch -eq $true -and $Match -isnot [L33tDictionaryMatch]) {
                if ($Match.Rank -le 10) {
                    $Result.Warning = [Warning]::Top10Passwords
                } elseif ($Match.Rank -le 100) {
                    $Result.Warning = [Warning]::Top100Passwords
                } else {
                    $Result.Warning = [Warning]::CommonPasswords
                }
            } elseif ([PasswordScoring]::CrackTimeToScore([PasswordScoring]::EntropyToCrackTime($Match.Entropy)) -le 1) {
                $Result.Warning = [Warning]::SimilarCommonPasswords
            }
        } elseif ($Match.DictionaryName.Equals('english')) {
            if ($IsSoleMatch -eq $true) {
                $Result.Warning = [Warning]::WordEasy
            }
        } elseif ($Match.DictionaryName.Equals('surnames') -or $Match.DictionaryName.Equals('male_names') -or $Match.DictionaryName.Equals('female_names')) {
            if ($IsSoleMatch -eq $true) {
                $Result.Warning = [Warning]::NameSurnamesEasy
            } else {
                $Result.Warning = [Warning]::CommonNameSurnamesEasy
            }
        } else {
            $Result.Warning = [Warning]::Empty
        }

        [string] $Word = $Match.Token
        if ([Regex]::IsMatch($Word, [PasswordScoring]::new().StartUpper)) {
            $Result.Suggestions.Add([Suggestion]::CapsDontHelp)
        } elseif ([Regex]::IsMatch($Word, [PasswordScoring]::new().AllUpper) -and $Word -ne $Word.ToLowerInvariant()) {
            $Result.Suggestions.Add([Suggestion]::AllCapsEasy)
        }

        # todo: add support for reversed words
        # if match.reversed and match.token.length >= 4
        #     suggestions.push "Reversed words aren't much harder to guess"

        if ($Match -is [L33tDictionaryMatch]) {
            $Result.Suggestions.Add([Suggestion]::PredictableSubstitutionsEasy)
        }
    }

    static [Result] MatchPassword([string] $Password, [System.Collections.Generic.IEnumerable[string]] $UserInputs = $null) {
        $zx = [Zxcvbn]::new([DefaultMatcherFactory]::new())
        return $zx.EvaluatePassword($Password, $UserInputs)
    }
}
