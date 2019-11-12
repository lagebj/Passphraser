enum Warning {
    Default
    StraightRow
    ShortKeyboardPatterns
    RepeatsLikeAaaEasy
    RepeatsLikeAbcSlighterHarder
    SequenceAbcEasy
    RecentYearsEasy
    DatesEasy
    Top10Passwords
    Top100Passwords
    CommonPasswords
    SimilarCommonPasswords
    WordEasy
    NameSurnamesEasy
    CommonNameSurnamesEasy
    Empty
}

enum Suggestion {
    Default
    AddAnotherWordOrTwo
    UseLongerKeyboardPattern
    AvoidRepeatedWordsAndChars
    AvoidSequences
    AvoidYearsAssociatedYou
    AvoidDatesYearsAssociatedYou
    CapsDontHelp
    AllCapsEasy
    ReversedWordEasy
    PredictableSubstitutionsEasy
    Empty
}

class Result {
    [double]$Entropy
    [long]$CalcTime
    [double]$CrackTime
    [string]$CrackTimeDisplay
    [int]$Score
    [System.Collections.Generic.IList[Match]]$MatchSequence
    [string]$Password
    [Warning]$Warning
    [System.Collections.Generic.List[Suggestion]]$Suggestions

    Result() {
        [System.Collections.Generic.List[Suggestion]]$this.suggestions = @()
    }
}
