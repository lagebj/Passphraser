class IMatcherFactory {
    static [System.Collections.Generic.IEnumerable[IMatcher]] CreateMatchers([System.Collections.Generic.IEnumerable[string]] $UserInputs) {
        return $UserInputs
    }
}
