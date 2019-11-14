class L33tMatcher : IMatcher {
        hidden [System.Collections.Generic.List[DictionaryMatcher]] $DictionaryMatchers
        hidden [System.Collections.Generic.Dictionary[char, string]] $Substitutions

        L33tMatcher([System.Collections.Generic.List[DictionaryMatcher]] $DictionaryMatchers) {
            $this.DictionaryMatchers = $DictionaryMatchers
            $Substitutions = $this.BuildSubstitutionsMap
        }

        L33tMatcher([DictionaryMatcher] $DictionaryMatcher) : base([System.Collections.Generic.List[DictionaryMatcher]]{$DictionaryMatchers}) {}

        [System.Collections.Generic.IEnumerable[Match]] MatchPassword([string] $Password) {
            $Subs = $this.EnumerateSubtitutions($this.GetRelevantSubstitutions($Password))

            $Matches = (
                foreach ($SubDict in $Subs) {
                    $sub_password = $this.TranslateString($SubDict, $Password)
                    foreach ($Matcher in $DictionaryMatchers) {
                        foreach ($Match in $Matcher.MatchPassword($sub_password).OfType([DictionaryMatch])) {
                            $Token = $Password.Substring($Match.i, ($Match.j - $Match.i + 1))
                            $UsedSubs = $SubDict | Where-Object {$Token.Contains($_.Key)}
                            if ($UsedSubs.Count -gt 0) {
                                [L33tDictionaryMatch]::new($Match = @{
                                    Token = $Token
                                    Subs = $UsedSubs.ToDictionary($_.Key, $_.Value)
                                })
                            }
                        }
                    }
                }).ToList

            foreach ($Match in $Matches) {
                $this.CalulateL33tEntropy($Match)
            }

            return $Matches
        }

        hidden [void] CalulateL33tEntropy([L33tDictionaryMatch] $Match) {
            $Possibilities = 0

            foreach ($kvp in $Match.Subs) {
                $SubbedChars = ($Match.Token | Where-Object {$_ -eq $kvp.Key}).Count
                $UnsubbedChars = ($Match.Token | Where-Object {$_ -eq $kvp.Value}).Count

                $Possibilities += [int][PasswordScoring]::Binomial($SubbedChars + $UnsubbedChars, $Sum)
                $Sum = [System.Linq.Enumerable]::Sum([System.Linq.Enumerable]::Range(0, [System.Math]::Min($SubbedChars, $UnsubbedChars) + 1))
            }

            $Entropy = [System.Math]::Log($Possibilities, 2)

            $Match.L33tEntropy = (
                if ($Entropy -lt 1) {
                    return 1
                } else {
                    $Entropy
                })
            $Match.Entropy += $Match.L33tEntropy

            $Match.Entropy -= $Match.UppercaseEntropy
            $Match.UppercaseEntropy = [PasswordScoring]::CalculateUppercaseEntropy($Match.Token)
            $Match.Entropy += $Match.UppercaseEntropy
        }

        hidden [string] TranslateString([System.Collections.Generic.Dictionary[char, char]] $CharMap, [string] $String) {
            $StringArray = $String.Split('').ToCharArray()
            [string]$String = $StringArray | ForEach-Object {
                if ($CharMap.ContainsKey($_)) {
                    $CharMap[$_]
                } else {
                    $_
                }
            }
            return $String
        }

XXX        hidden [System.Collections.Generic.Dictionary[char, string]] GetRelevantSubstitutions([string] $Password) {
            return ($this.Substitutions | Where-Object {$_.Value.Any | Where-Object {$Password.Contains($_)}}).ToDictionary() .Where(kv => kv.Value.Any(lc => password.Contains(lc))).ToDictionary(kv => kv.Key, kv => new String(kv.Value.Where(lc => password.Contains(lc)).ToArray()));
        }

        private List<Dictionary<char, char>> EnumerateSubtitutions(Dictionary<char, string> table)
        {
            // Produce a list of maps from l33t character to normal character. Some substitutions can be more than one normal character though,
            //  so we have to produce an entry that maps from the l33t char to both possibilities

            //XXX: This function produces different combinations to the original in zxcvbn. It may require some more work to get identical.
            
            //XXX: The function is also limited in that it only ever considers one substitution for each l33t character (e.g. ||ke could feasibly
            //     match 'like' but this method would never show this). My understanding is that this is also a limitation in zxcvbn and so I
            //     feel no need to correct it here.

            var subs = new List<Dictionary<char, char>>();
            subs.Add(new Dictionary<char, char>()); // Must be at least one mapping dictionary to work

            foreach (var mapPair in table)
            {
                var normalChar = mapPair.Key;

                foreach (var l33tChar in mapPair.Value)
                {
                    // Can't add while enumerating so store here
                    var addedSubs = new List<Dictionary<char, char>>();

                    foreach (var subDict in subs)
                    {
                        if (subDict.ContainsKey(l33tChar))
                        {
                            // This mapping already contains a corresponding normal character for this character, so keep the existing one as is
                            //   but add a duplicate with the mappring replaced with this normal character
                            var newSub = new Dictionary<char, char>(subDict);
                            newSub[l33tChar] = normalChar;
                            addedSubs.Add(newSub);
                        }
                        else
                        {
                            subDict[l33tChar] = normalChar;
                        }
                    }

                    subs.AddRange(addedSubs);
                }
            }

            return subs;
        }

        private Dictionary<char, string> BuildSubstitutionsMap()
        {
            // Is there an easier way of building this table?
            var subs = new Dictionary<char, string>();

            subs['a'] = "4@";
            subs['b'] = "8";
            subs['c'] = "({[<";
            subs['e'] = "3";
            subs['g'] = "69";
            subs['i'] = "1!|";
            subs['l'] = "1|7";
            subs['o'] = "0";
            subs['s'] = "$5";
            subs['t'] = "+7";
            subs['x'] = "%";
            subs['z'] = "2";

            return subs;
        }
    }

    /// <summary>
    /// L33tMatcher results are like dictionary match results with some extra information that pertains to the extra entropy that
    /// is garnered by using substitutions.
    /// </summary>
    public class L33tDictionaryMatch : DictionaryMatch
    {
        /// <summary>
        /// The extra entropy from using l33t substitutions
        /// </summary>
        public double L33tEntropy { get; set; }

        /// <summary>
        /// The character mappings that are in use for this match
        /// </summary>
        public Dictionary<char, char> Subs { get; set; }

        /// <summary>
        /// Create a new l33t match from a dictionary match
        /// </summary>
        /// <param name="dm">The dictionary match to initialise the l33t match from</param>
        public L33tDictionaryMatch(DictionaryMatch dm)
        {
            this.BaseEntropy = dm.BaseEntropy;
            this.Cardinality = dm.Cardinality;
            this.DictionaryName = dm.DictionaryName;
            this.Entropy = dm.Entropy;
            this.i = dm.i;
            this.j = dm.j;
            this.MatchedWord = dm.MatchedWord;
            this.Pattern = dm.Pattern;
            this.Rank = dm.Rank;
            this.Token = dm.Token;
            this.UppercaseEntropy = dm.UppercaseEntropy;

            Subs = new Dictionary<char, char>();
        }

        /// <summary>
        /// Create an empty l33t match
        /// </summary>
        public L33tDictionaryMatch()
        {
            Subs = new Dictionary<char, char>();
        }
    }
}
