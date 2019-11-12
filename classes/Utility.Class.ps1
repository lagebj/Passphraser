enum Translation {
    English
    German
    Norwegian
}

static class Utility {
    static [string]$DisplayTime(
        [double]$Seconds,
        [Translation]$Translation = [Translation]::English) {
        [long]$Minute = 60
        [long]$Hour = $Minute * 60
        [long]$Day = $Hour * 24
        [long]$Month = $Day * 31
        [long]$Year = $Month * 12
        [long]$Century = $Year * 100;

        if ($Seconds -lt $Minute) {
            return GetTranslation('instant', $Translation)
        } elseif ($Seconds -lt $Hour) {
            return [string]::Format('{0} ' + $this.GetTranslation('minutes', $Translation), (1 + [System.Math]::Ceiling($Seconds / $Minute)))
        } elseif ($Seconds -lt $Day) {
            return [string]::Format('{0} ' + $this.GetTranslation('hours', $Translation), (1 + [System.Math]::Ceiling($Seconds / $Hour)))
        } elseif ($Seconds -lt $Month) {
            return [string]::Format('{0} ' + $this.GetTranslation('days', $Translation), (1 + [System.Math]::Ceiling($Seconds / $Day)))
        } elseif ($Seconds -lt $Year) {
            return [string]::Format('{0} ' + $this.GetTranslation('months', $Translation), (1 + [System.Math]::Ceiling($Seconds / $Month)))
        } elseif ($Seconds -lt $Century) {
            return [string]::Format('{0} ' + $this.GetTranslation('years', $Translation), (1 + [System.Math]::Ceiling($Seconds / $Year)))
        } else {
            return $this.GetTranslation('centuries', $Translation)
        }
    }

    hidden static [string]GetTranslation([string]$Matcher, [Translation]$Translation) {
        [string]$Translated

        switch ($Matcher) {
            'instant' {
                switch ($Translation) {
                    ([Translation]::German) {
                        $Translated = 'unmittelbar'
                        break
                    }
                    ([Translation]::Norwegian) {
                        $Translated = 'umiddelbart'
                        break
                    }
                    default {
                        translated = 'instant'
                        break
                    }
                }
                break
            }
            'minutes' {
                switch ($Translation) {
                    ([Translation]::German) {
                        $Translated = 'Minuten'
                        break
                    }
                    ([Translation]::Norwegian) {
                        $Translated = 'minutter'
                        break
                    }
                    default {
                        translated = 'minutes'
                        break
                    }
                }
                break
            }
            'hours' {
                switch ($Translation) {
                    ([Translation]::German) {
                        $Translated = 'Stunden'
                        break
                    }
                    ([Translation]::Norwegian) {
                        $Translated = 'timer'
                        break
                    }
                    default {
                        translated = 'hours'
                        break
                    }
                }
                break
            }
            'days' {
                switch ($Translation) {
                    ([Translation]::German) {
                        $Translated = 'Tage'
                        break
                    }
                    ([Translation]::Norwegian) {
                        $Translated = 'dager'
                        break
                    }
                    default {
                        translated = 'days'
                        break
                    }
                }
                break
            }
            'months' {
                switch ($Translation) {
                    ([Translation]::German) {
                        $Translated = 'Monate'
                        break
                    }
                    ([Translation]::Norwegian) {
                        $Translated = 'måneder'
                        break
                    }
                    default {
                        translated = 'months'
                        break
                    }
                }
                break
            }
            'years' {
                switch ($Translation) {
                    ([Translation]::German) {
                        $Translated = 'Jahre'
                        break
                    }
                    ([Translation]::Norwegian) {
                        $Translated = 'år'
                        break
                    }
                    default {
                        translated = 'years'
                        break
                    }
                }
                break
            }
            'centuries' {
                switch ($Translation) {
                    ([Translation]::German) {
                        $Translated = 'Jahrhunderte'
                        break
                    }
                    ([Translation]::Norwegian) {
                        $Translated = 'århundre'
                        break
                    }
                    default {
                        translated = 'centuries'
                        break
                    }
                }
                break
            }
            default {
                $Translated = $Matcher
                break
            }
        }

            return $Translated
    }

    static [string]$F([string]$String, [object[]]$Arguments) {
        return [string]::Format($String, $Arguments)
    }

    static [string]$StringReverse([string]$String) {
        [char[]]$StringArray = $String.ToCharArray()
        [array]::Reverse($StringArray)
        return $StringArray -join ''
    }

    static [bool]IntParseSubstring([string]$String, [int]$StartIndex, [int]$Length, [int]$Result) {
        return Int32.TryParse(str.Substring(startIndex, length), out r);
        return [int]::TryParse($String.Substring($StartIndex, $Length), [ref]$Result) 
    }

            public static int ToInt(this string str)
            {
                int r = 0;
                Int32.TryParse(str, out r);
                return r;
            }

            public static IEnumerable<string> GetEmbeddedResourceLines(string resourceName)
            {
                var asm = Assembly.GetExecutingAssembly();
                if (!asm.GetManifestResourceNames().Contains(resourceName)) return null; // Not an embedded resource

                var lines = new List<string>();

                using (var stream = asm.GetManifestResourceStream(resourceName))
                using (var text = new StreamReader(stream))
                {
                    while (!text.EndOfStream) {
                        lines.Add(text.ReadLine());
                    }
                }

                return lines;
            }

            public static string GetWarning(Warning warning, Translation translation = Translation.English)
            {
                string translated;

                switch (warning) {
                    case Warning.StraightRow:
                    switch (translation) {
                        case Translation.German:
                        translated = "";
                        break;
                        case Translation.France:
                        translated = "";
                        break;
                        default:
                        translated = "Straight rows of keys are easy to guess";
                        break;
                    }
                    break;

                    case Warning.ShortKeyboardPatterns:
                    switch (translation) {
                        case Translation.German:
                        translated = "";
                        break;
                        case Translation.France:
                        translated = "";
                        break;
                        default:
                        translated = "Short keyboard patterns are easy to guess";
                        break;
                    }
                    break;

                    case Warning.RepeatsLikeAaaEasy:
                    switch (translation) {
                        case Translation.German:
                        translated = "";
                        break;
                        case Translation.France:
                        translated = "";
                        break;
                        default:
                        translated = "Repeats like \"aaa\" are easy to guess";
                        break;
                    }
                    break;

                    case Warning.RepeatsLikeAbcSlighterHarder:
                    switch (translation) {
                        case Translation.German:
                        translated = "";
                        break;
                        case Translation.France:
                        translated = "";
                        break;
                        default:
                        translated = "Repeats like \"abcabcabc\" are only slightly harder to guess than \"abc\"";
                        break;
                    }
                    break;
                    case Warning.SequenceAbcEasy:
                    switch (translation) {
                        case Translation.German:
                        translated = "";
                        break;
                        case Translation.France:
                        translated = "";
                        break;
                        default:
                        translated = "Sequences like abc or 6543 are easy to guess";
                        break;
                    }
                    break;
                    case Warning.RecentYearsEasy:
                    switch (translation) {
                        case Translation.German:
                        translated = "";
                        break;
                        case Translation.France:
                        translated = "";
                        break;
                        default:
                        translated = "Recent years are easy to guess";
                        break;
                    }
                    break;
                    case Warning.DatesEasy:
                    switch (translation) {
                        case Translation.German:
                        translated = "";
                        break;
                        case Translation.France:
                        translated = "";
                        break;
                        default:
                        translated = "Dates are often easy to guess";
                        break;
                    }
                    break;
                    case Warning.Top10Passwords:
                    switch (translation) {
                        case Translation.German:
                        translated = "";
                        break;
                        case Translation.France:
                        translated = "";
                        break;
                        default:
                        translated = "This is a top-10 common password";
                        break;
                    }
                    break;
                    case Warning.Top100Passwords:
                    switch (translation) {
                        case Translation.German:
                        translated = "";
                        break;
                        case Translation.France:
                        translated = "";
                        break;
                        default:
                        translated = "This is a top-100 common password";
                        break;
                    }
                    break;
                    case Warning.CommonPasswords:
                    switch (translation) {
                        case Translation.German:
                        translated = "";
                        break;
                        case Translation.France:
                        translated = "";
                        break;
                        default:
                        translated = "This is a very common password";
                        break;
                    }
                    break;
                    case Warning.SimilarCommonPasswords:
                    switch (translation) {
                        case Translation.German:
                        translated = "";
                        break;
                        case Translation.France:
                        translated = "";
                        break;
                        default:
                        translated = "This is similar to a commonly used password";
                        break;
                    }
                    break;
                    case Warning.WordEasy:
                    switch (translation) {
                        case Translation.German:
                        translated = "";
                        break;
                        case Translation.France:
                        translated = "";
                        break;
                        default:
                        translated = "A word by itself is easy to guess";
                        break;
                    }
                    break;
                    case Warning.NameSurnamesEasy:
                    switch (translation) {
                        case Translation.German:
                        translated = "";
                        break;
                        case Translation.France:
                        translated = "";
                        break;
                        default:
                        translated = "Names and surnames by themselves are easy to guess";
                        break;
                    }
                    break;
                    case Warning.CommonNameSurnamesEasy:
                    switch (translation) {
                        case Translation.German:
                        translated = "";
                        break;
                        case Translation.France:
                        translated = "";
                        break;
                        default:
                        translated = "Common names and surnames are easy to guess";
                        break;
                    }
                    break;

                    case Warning.Empty:
                    switch (translation) {
                        case Translation.German:
                        translated = "";
                        break;
                        case Translation.France:
                        translated = "";
                        break;
                        default:
                        translated = "";
                        break;
                    }
                    break;

                    default:
                    translated = "";
                    break;
                }
                return translated;
            }

            public static string GetSuggestion(Suggestion suggestion, Translation translation = Translation.English)
            {
                string translated;

                switch (suggestion) {
                    case Suggestion.AddAnotherWordOrTwo:
                    switch (translation) {
                        case Translation.German:
                        translated = "";
                        break;
                        case Translation.France:
                        translated = "";
                        break;
                        default:
                        translated = "Add another word or two. Uncommon words are better.";
                        break;
                    }
                    break;

                    case Suggestion.UseLongerKeyboardPattern:
                    switch (translation) {
                        case Translation.German:
                        translated = "";
                        break;
                        case Translation.France:
                        translated = "";
                        break;
                        default:
                        translated = "Use a longer keyboard pattern with more turns";
                        break;
                    }
                    break;

                    case Suggestion.AvoidRepeatedWordsAndChars:
                    switch (translation) {
                        case Translation.German:
                        translated = "";
                        break;
                        case Translation.France:
                        translated = "";
                        break;
                        default:
                        translated = "Avoid repeated words and characters";
                        break;
                    }
                    break;

                    case Suggestion.AvoidSequences:
                    switch (translation) {
                        case Translation.German:
                        translated = "";
                        break;
                        case Translation.France:
                        translated = "";
                        break;
                        default:
                        translated = "Avoid sequences";
                        break;
                    }
                    break;
                    case Suggestion.AvoidYearsAssociatedYou:
                    switch (translation) {
                        case Translation.German:
                        translated = "";
                        break;
                        case Translation.France:
                        translated = "";
                        break;
                        default:
                        translated = "Avoid recent years \n Avoid years that are associated with you";
                        break;
                    }
                    break;
                    case Suggestion.AvoidDatesYearsAssociatedYou:
                    switch (translation) {
                        case Translation.German:
                        translated = "";
                        break;
                        case Translation.France:
                        translated = "";
                        break;
                        default:
                        translated = "Avoid dates and years that are associated with you";
                        break;
                    }
                    break;
                    case Suggestion.CapsDontHelp:
                    switch (translation) {
                        case Translation.German:
                        translated = "";
                        break;
                        case Translation.France:
                        translated = "";
                        break;
                        default:
                        translated = "Capitalization doesn't help very much";
                        break;
                    }
                    break;
                    case Suggestion.AllCapsEasy:
                    switch (translation) {
                        case Translation.German:
                        translated = "";
                        break;
                        case Translation.France:
                        translated = "";
                        break;
                        default:
                        translated = "All-uppercase is almost as easy to guess as all-lowercase";
                        break;
                    }
                    break;
                    case Suggestion.ReversedWordEasy:
                    switch (translation) {
                        case Translation.German:
                        translated = "";
                        break;
                        case Translation.France:
                        translated = "";
                        break;
                        default:
                        translated = "Reversed words aren't much harder to guess";
                        break;
                    }
                    break;
                    case Suggestion.PredictableSubstitutionsEasy:
                    switch (translation) {
                        case Translation.German:
                        translated = "";
                        break;
                        case Translation.France:
                        translated = "";
                        break;
                        default:
                        translated = "Predictable substitutions like '@' instead of 'a' don't help very much";
                        break;
                    }
                    break;

                    case Suggestion.Empty:
                    switch (translation) {
                        case Translation.German:
                        translated = "";
                        break;
                        case Translation.France:
                        translated = "";
                        break;
                        default:
                        translated = "";
                        break;
                    }
                    break;
                    default:
                    translated = "Use a few words, avoid common phrases \n No need for symbols, digits, or uppercase letters";
                    break;
                }
                return translated;
            }

        }
    }