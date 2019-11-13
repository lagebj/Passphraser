﻿class DictionaryMatcher : IMatcher {
    [string]$DictionaryPattern = 'dictionary'

    hidden [string]$DictionaryName
    hidden [System.Lazy[System.Collections.Generic.Dictionary[string, int]]]$RankedDictionary = @{}

    DictionaryMatcher([string]$Name, [string]$WordListPath) {
        $this.DictionaryName = $Name
        $this.RankedDictionary = new Lazy<Dictionary<string, int>>(() => BuildRankedDictionary(wordListPath));
    }

    DictionaryMatcher([string]$Name, [System.Collections.Generic.IEnumerable[string]]$WordList) {
        $this.DictionaryName = $Name
        $this.RankedDictionary = new Lazy<Dictionary<string, int>>(() => BuildRankedDictionary(wordList.Select(w => w.ToLower())));
    }

    [System.Collections.Generic.IEnumerable[Match]]MatchPassword([string]$Password) {
        [string]$PasswordLower = $Password.ToLower()

        $Matches = (
            $i = [System.Linq.Enumerable]::Range(0, $Password.Length)
            $j = [System.Linq.Enumerable]::Range($i, ($Password.Length - $i))
            $psub = $PasswordLower.Substring($i, ($j -$i + 1))
            if ($this.RankedDictionary.Value.ContainsKey($psub)) {
                [DictionaryMatch]@{
                    Pattern = $this.DictionaryPattern
                    i = $i
                    j = $j
                    Token = $Password.Substring($i, ($j - $i + 1))
                    MatchedWord = $Psub
                    Rank = $this.RankedDictionary.Value[psub]
                    DictionaryName = $this.DictionaryName
                    Cardinality = $this.RankedDictionary.Value.Count
                }
            }).ToList()

        foreach ($Match in $Matches) {
            $this.CalculateEntropyForMatch($Match)
        }

        return $Matches
    }

    hidden [void]CalculateEntropyForMatch([DictionaryMatch]$Match) {
        $Match.BaseEntropy = [System.Math]::Log($Match.Rank, 2)
        $Match.UppercaseEntropy = PasswordScoring.CalculateUppercaseEntropy($Match.Token)
        
        $Match.Entropy = $Match.BaseEntropy + $Match.UppercaseEntropy
    }

    hidden [System.Collections.Generic.Dictionary[string, int]]BuildRankedDictionary([string]$WordListFile) {
        $Lines = Utility.GetEmbeddedResourceLines("Zxcvbn.Dictionaries.{0}".F($WordListFile)) ?? File.ReadAllLines(wordListFile);

        return BuildRankedDictionary(lines);
    }

        private Dictionary<string, int> BuildRankedDictionary(IEnumerable<string> wordList)
        {
            var dict = new Dictionary<string, int>();

            var i = 1;
            foreach (var word in wordList)
            {
                // The word list is assumed to be in increasing frequency order
                dict[word] = i++;
            }

            return dict;
        }
    }