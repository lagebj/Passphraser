class Zxcvbn {
        hidden [string]$BruteforcePattern = 'bruteforce'
        hidden [IMatcherFactory]$MatcherFactory
        hidden [Translation]$Translation

        Zxcvbn([Translation]Ttranslation = [Translation]::English) : $this.DefaultMatcherFactory() {
            $this.Translation = $Translation
        }

        Zxcvbn([IMatcherFactory]$MatcherFactory, [Translation]$Translation = [Translation]::English) {
            $this.MatcherFactory = $MatcherFactory
            $this.Translation = $Translation
        }

        [Result]EvaluatePassword([string]$Password, [System.Collections.Generic.IEnumerable[string]]$UserInputs = $null) {
            $UserInputs = $UserInputs ?? new string[0];

            [System.Collections.Generic.IEnumerable[Match]]$Matches = [System.Collections.Generic.List[Match]]::new()
            
            $Timer = [System.Diagnostics.Stopwatch]::StartNew()
            
            foreach ($Matcher in $MatcherFactory.CreateMatchers($UserInputs)) {
                $Matches = $Matches.Union($Matcher.MatchPassword($Password))
            }

            $Result = FindMinimumEntropyMatch($Password, $Matches)

            $Timer.Stop()
            $Result.CalcTime = $Timer.ElapsedMilliseconds

            return $Result
        }

        hidden [Result]FindMinimumEntropyMatch([string]$Password, [System.Collections.Generic.IEnumerable[Match]]$Matches) {
            $bruteforce_cardinality = PasswordScoring.PasswordCardinality($Password)

            // Minimum entropy up to position k in the password
            $MinimumEntropyToIndex = [double]::new($Password.Length)
            $BestMatchForIndex = [Match]::new()[$Password.Length]
 
            for ($k = 0; $k -lt $Password.Length; $k++) {
                $MinimumEntropyToIndex[$k] = (
                    if ($k -eq 0) {
                        0
                    } else {
                        $MinimumEntropyToIndex[$k - 1]
                    }) + [System.Math]::Log($bruteforce_cardinality, 2)

                foreach ($Match in $Matches | Where-Object {$_.j -eq $k}) {
                    $candidate_entropy = (
                        if ($Match.i -le 0) {
                            0
                        } else {
                            $MinimumEntropyToIndex[$Match.i - 1]) + $Match.Entropy
                        }
                    if ($candidate_entropy -lt $MinimumEntropyToIndex[$k]){
                        $MinimumEntropyToIndex[$k] = $candidate_entropy
                        $BestMatchForIndex[$k] = $Match
                    }
                }
            }

            [System.Collections.Generic.List[Match]]$MatchSequence = @()
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
                    Pattern = $BruteforcePattern
                    Entropy = [System.Math]::Log([System.Math]:Pow($bruteforce_cardinality, $Password.Length), 2)
                })
            } else {
                [System.Collections.Generic.List[Match]]$MatchSequenceCopy = @()
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
                                Pattern = $BruteforcePattern
                                Entropy = [System.Math]::Log([System.Math]::Pow($bruteforce_cardinality, ($ne - $ns + 1)), 2)
                        })
                    }
                }

                $MatchSequence = $MatchSequenceCopy
            }


            var minEntropy = (password.Length == 0 ? 0 : minimumEntropyToIndex[password.Length - 1]);
            var crackTime = PasswordScoring.EntropyToCrackTime(minEntropy);

            var result = new Result();
            result.Password = password;
            result.Entropy = Math.Round(minEntropy, 3);
            result.MatchSequence = matchSequence;
            result.CrackTime = Math.Round(crackTime, 3);
            result.CrackTimeDisplay = Utility.DisplayTime(crackTime, this.translation);
            result.Score = PasswordScoring.CrackTimeToScore(crackTime);


            //starting feedback
            if ((matchSequence == null) || (matchSequence.Count() == 0))
            {
                result.warning = Warning.Default;
                result.suggestions.Clear();
                result.suggestions.Add(Suggestion.Default);
            }
            else
            {
                //no Feedback if score is good or great
                if (result.Score > 2)
                {
                    result.warning = Warning.Empty;
                    result.suggestions.Clear();
                    result.suggestions.Add(Suggestion.Empty);
                }
                else
                {
                    //tie feedback to the longest match for longer sequences                   
                    Match longestMatch = GetLongestMatch(matchSequence);
                    GetMatchFeedback(longestMatch, matchSequence.Count() == 1, result);
                    result.suggestions.Insert(0,Suggestion.AddAnotherWordOrTwo);
                }


            }
            return result;
        }

        private Match GetLongestMatch(List<Match> matchSequence)
        {
            Match longestMatch;

            if ((matchSequence != null) && (matchSequence.Count() > 0))
            {
                longestMatch = matchSequence[0];
                foreach (Match match in matchSequence)
                {
                    if (match.Token.Length > longestMatch.Token.Length)
                        longestMatch = match;
                }
            }
            else
                longestMatch = new Match();

            return longestMatch;
        }

        private void GetMatchFeedback(Match match, bool isSoleMatch, Result result)
        {
            switch (match.Pattern)
            {
                case "dictionary":
                    GetDictionaryMatchFeedback((DictionaryMatch)match, isSoleMatch, result);
                break;

                case "spatial":
                    SpatialMatch spatialMatch = (SpatialMatch) match;

                    if (spatialMatch.Turns == 1)
                        result.warning = Warning.StraightRow;
                    else
                        result.warning = Warning.ShortKeyboardPatterns;

                    result.suggestions.Clear();
                    result.suggestions.Add(Suggestion.UseLongerKeyboardPattern);
                    break;

                case "repeat":
                    //todo: add support for repeated sequences longer than 1 char
                  //  if(match.Token.Length == 1)
                        result.warning = Warning.RepeatsLikeAaaEasy;
                  //  else
                 //       result.warning = Warning.RepeatsLikeAbcSlighterHarder;

                    result.suggestions.Clear();
                    result.suggestions.Add(Suggestion.AvoidRepeatedWordsAndChars);
                    break;

                case "sequence":
                    result.warning = Warning.SequenceAbcEasy;

                    result.suggestions.Clear();
                    result.suggestions.Add(Suggestion.AvoidSequences);
                    break;

                //todo: add support for recent_year, however not example exist on https://dl.dropboxusercontent.com/u/209/zxcvbn/test/index.html


                case "date":
                    result.warning = Warning.DatesEasy;

                    result.suggestions.Clear();
                    result.suggestions.Add(Suggestion.AvoidDatesYearsAssociatedYou);
                    break;
            }
        }

        private void GetDictionaryMatchFeedback(DictionaryMatch match, bool isSoleMatch, Result result)
        {
            if (match.DictionaryName.Equals("passwords"))
            {
                //todo: add support for reversed words
                if (isSoleMatch == true && !(match is L33tDictionaryMatch))
                {
                        if (match.Rank <= 10)
                            result.warning = Warning.Top10Passwords;
                        else if (match.Rank <= 100)
                            result.warning = Warning.Top100Passwords;
                        else
                            result.warning = Warning.CommonPasswords;
                }
                else if (PasswordScoring.CrackTimeToScore(PasswordScoring.EntropyToCrackTime(match.Entropy)) <= 1)
                {
                    result.warning = Warning.SimilarCommonPasswords;
                }
            }
            else if (match.DictionaryName.Equals("english"))
            {
                if (isSoleMatch == true)
                    result.warning = Warning.WordEasy;
            }
            else if (match.DictionaryName.Equals("surnames") ||
                     match.DictionaryName.Equals("male_names") ||
                     match.DictionaryName.Equals("female_names"))
            {
                if (isSoleMatch == true)
                    result.warning = Warning.NameSurnamesEasy;
                else
                    result.warning = Warning.CommonNameSurnamesEasy;
            }
            else
            {
                result.warning = Warning.Empty;
            }

            string word = match.Token;
            if (Regex.IsMatch(word, PasswordScoring.StartUpper))
            {
                result.suggestions.Add(Suggestion.CapsDontHelp);
            }
            else if (Regex.IsMatch(word, PasswordScoring.AllUpper) && !word.Equals(word.ToLowerInvariant()))
            {
                result.suggestions.Add(Suggestion.AllCapsEasy);
            }

            //todo: add support for reversed words
            //if match.reversed and match.token.length >= 4
            //    suggestions.push "Reversed words aren't much harder to guess"

            if (match is L33tDictionaryMatch)
            {
                result.suggestions.Add(Suggestion.PredictableSubstitutionsEasy);
            }
        }

        /// <summary>
        /// <para>A static function to match a password against the default matchers without having to create
        /// an instance of Zxcvbn yourself, with supplied user data. </para>
        /// 
        /// <para>Supplied user data will be treated as another kind of dictionary matching.</para>
        /// </summary>
        /// <param name="password">the password to test</param>
        /// <param name="userInputs">optionally, the user inputs list</param>
        /// <returns>The results of the password evaluation</returns>
        public static Result MatchPassword(string password, IEnumerable<string> userInputs = null)
        {
            var zx = new Zxcvbn(new DefaultMatcherFactory());
            return zx.EvaluatePassword(password, userInputs);
        }

    }
