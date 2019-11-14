class L33tMatcher : IMatcher {
        hidden [System.Collections.Generic.List[DictionaryMatcher]] $DictionaryMatchers
        hidden [Dictionary[char, string]] $Substitutions

        L33tMatcher([System.Collections.Generic.List[DictionaryMatcher]] $DictionaryMatchers) {
            $this.DictionaryMatchers = $DictionaryMatchers
            $Substitutions = $this.BuildSubstitutionsMap
        }

        L33tMatcher([DictionaryMatcher] $DictionaryMatcher) : base([System.Collections.Generic.List[DictionaryMatcher]]{ $DictionaryMatcher }) {}

        [System.Collections.Generic.IEnumerable[Match]] MatchPassword([string] $Password) {
            $Subs = $this.EnumerateSubtitutions($this.GetRelevantSubstitutions($Password))

            $Matches = (from $SubDict in $Subs
                          let sub_password = TranslateString(subDict, password)
                          from matcher in dictionaryMatchers
                          from match in matcher.MatchPassword(sub_password).OfType<DictionaryMatch>()
                          let token = password.Substring(match.i, match.j - match.i + 1)
                          let usedSubs = subDict.Where(kv => token.Contains(kv.Key)) // Count subs ised in matched token
                          where usedSubs.Count() > 0 // Only want matches where substitutions were used
                          select new L33tDictionaryMatch(match)
                          {
                              Token = token,
                              Subs = usedSubs.ToDictionary(kv => kv.Key, kv => kv.Value)
                          }).ToList();

            $Matches = (
                foreach ($SubDict in $Subs) {
                    $sub_password = $this.TranslateString($SubDict, $Password)
                    foreach ($Matcher in $DictionaryMatchers) {
                        foreach ($Match in $Matcher.MatchPassword($sub_password).OfType([DictionaryMatch])) {
                            $Token = $Password.Substring($Match.i, ($Match.j - $Match.i + 1))
                            $UsedSubs = $SubDict | Where-Object {$Token.Contains($_.Key)}
                        }
                    }
                }
            )

            foreach ($Match in $Matches) {
                $this.CalulateL33tEntropy($Match)
            }

            return $Matches
        }

        private void CalulateL33tEntropy(L33tDictionaryMatch match)
        {
            // I'm a bit dubious about this function, but I have duplicated zxcvbn functionality regardless

            var possibilities = 0;

            foreach (var kvp in match.Subs)
            {
                var subbedChars = match.Token.Where(c => c == kvp.Key).Count();
                var unsubbedChars = match.Token.Where(c => c == kvp.Value).Count(); // Won't this always be zero?

                possibilities += Enumerable.Range(0, Math.Min(subbedChars, unsubbedChars) + 1).Sum(i => (int)PasswordScoring.Binomial(subbedChars + unsubbedChars, i));
            }

            var entropy = Math.Log(possibilities, 2);

            // In the case of only a single subsitution (e.g. 4pple) this would otherwise come out as zero, so give it one bit
            match.L33tEntropy = (entropy < 1 ? 1 : entropy);
            match.Entropy += match.L33tEntropy;

            // We have to recalculate the uppercase entropy -- the password matcher will have used the subbed password not the original text
            match.Entropy -= match.UppercaseEntropy;
            match.UppercaseEntropy = PasswordScoring.CalculateUppercaseEntropy(match.Token);
            match.Entropy += match.UppercaseEntropy;
        }

        private string TranslateString(Dictionary<char, char> charMap, string str)
        {
            // Make substitutions from the character map wherever possible
            return new String(str.Select(c => charMap.ContainsKey(c) ? charMap[c] : c).ToArray());
        }

        private Dictionary<char, string> GetRelevantSubstitutions(string password)
        {
            // Return a map of only the useful substitutions, i.e. only characters that the password
            //   contains a substituted form of
            return substitutions.Where(kv => kv.Value.Any(lc => password.Contains(lc)))
                                .ToDictionary(kv => kv.Key, kv => new String(kv.Value.Where(lc => password.Contains(lc)).ToArray()));
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
