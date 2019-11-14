class DefaultMatcherFactory : IMatcherFactory {
    [System.Collections.Generic.List[IMatcher]]$Matchers = @()

    DefaultMatcherFactory() {
        $DictionaryMatchers = [System.Collections.Generic.List[DictionaryMatcher]]@(
            [DictionaryMatcher]::new("passwords", "passwords.lst")
            [DictionaryMatcher]::new("english", "english.lst")
            [DictionaryMatcher]::new("male_names", "male_names.lst")
            [DictionaryMatcher]::new("female_names", "female_names.lst")
            [DictionaryMatcher]::new("surnames", "surnames.lst")
        )

        $this.Matchers = [System.Collections.Generic.List[IMatcher]]@(
            [RepeatMatcher]::new()
            [SequenceMatcher]::new()
            [RegexMatcher]::new("\d{3,}", 10, $true, 'digits')
            [RegexMatcher]::new("19\d\d|200\d|201\d", 119, $false, 'year')
            [DateMatcher]::new()
            [SpatialMatcher]::new()
        )

        $this.Matchers.AddRange($DictionaryMatchers)
        $this.Matchers.Add([L33tMatcher]::new($DictionaryMatchers))
    }

    [System.Collections.Generic.IEnumerable[IMatcher]] CreateMatchers([System.Collections.Generic.IEnumerable[string]] $UserInputs) {
        $UserInputDict = [DictionaryMatcher]::new('user_inputs', $UserInputs)
        $LeetUser = [L33tMatcher]::new($UserInputDict)

        return $this.Matchers.Union([System.Collections.Generic.List[IMatcher]]@(
            $UserInputDict,
            $LeetUser
        )
    }
}
