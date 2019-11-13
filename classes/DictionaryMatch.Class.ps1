class DictionaryMatch : Match {
    [string]$MatchedWord
    [int]$Rank
    [string]$DictionaryName
    [double]$BaseEntropy
    [double]$UppercaseEntropy
}