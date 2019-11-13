enum Translation {
    English
    German
    Norwegian
}

class Utility {
    static [string ]DisplayTime(
        [double]$Seconds,
        [Translation]$Translation = [Translation]::English) {
        [long]$Minute = 60
        [long]$Hour = $Minute * 60
        [long]$Day = $Hour * 24
        [long]$Month = $Day * 31
        [long]$Year = $Month * 12
        [long]$Century = $Year * 100;

        if ($Seconds -lt $Minute) {
            return [Utility]::GetTranslation('instant', $Translation)
        } elseif ($Seconds -lt $Hour) {
            return [string]::Format('{0} ' + [Utility]::GetTranslation('minutes', $Translation), (1 + [System.Math]::Ceiling($Seconds / $Minute)))
        } elseif ($Seconds -lt $Day) {
            return [string]::Format('{0} ' + [Utility]::GetTranslation('hours', $Translation), (1 + [System.Math]::Ceiling($Seconds / $Hour)))
        } elseif ($Seconds -lt $Month) {
            return [string]::Format('{0} ' + [Utility]::GetTranslation('days', $Translation), (1 + [System.Math]::Ceiling($Seconds / $Day)))
        } elseif ($Seconds -lt $Year) {
            return [string]::Format('{0} ' + [Utility]::GetTranslation('months', $Translation), (1 + [System.Math]::Ceiling($Seconds / $Month)))
        } elseif ($Seconds -lt $Century) {
            return [string]::Format('{0} ' + [Utility]::GetTranslation('years', $Translation), (1 + [System.Math]::Ceiling($Seconds / $Year)))
        } else {
            return [Utility]::GetTranslation('centuries', $Translation)
        }
    }

    hidden static [string] GetTranslation([string]$Matcher, [Translation]$Translation) {
        [string]$Translated = ''

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

    static [string]F([string]$String, [object[]]$Arguments) {
        return [string]::Format($String, $Arguments)
    }

    static [string]StringReverse([string]$String) {
        [char[]]$StringArray = $String.ToCharArray()
        [array]::Reverse($StringArray)
        return $StringArray -join ''
    }

    static [bool] IntParseSubstring([string]$String, [int]$StartIndex, [int]$Length, [ref]$Result) {
        return [int]::TryParse($String.Substring($StartIndex, $Length), [ref]$Result) 
    }

    static [int]ToInt([string]$String)
    {
        [int]$Result = 0;
        [int]::TryParse($String,[ref]$Result)
        return $Result
    }

    static [System.Collections.Generic.IEnumerable[string]] GetEmbeddedResourceLines([string]$ResourceName) {
        $Assembly = [System.Reflection.Assembly]::GetExecutingAssembly()
        if (-not $Assembly.GetManifestResourceNames().Contains($ResourceName)) {
            return $null
        }

        [System.Collections.Generic.List[string]]$Lines = @()

        $Stream = $Assembly.GetManifestResourceStream($ResourceName)
        $Text = [System.IO.StreamReader]::new($Stream)

        while (-not $Text.EndOfStream) {
            $Lines.Add($Text.ReadLine())
        }

        return $Lines
    }

    static [string] GetWarning([Warning]$Warning, [Translation]$Translation = [Translation]::English) {
        [string]$Translated = ''

        switch ($Warning) {
            ([Warning]::StraightRow) {
                switch ($Translation) {
                    ([Translation]::German) {
                        $Translated = ''
                        break
                    }
                    ([Translation]::Norwegian) {
                        $Translated = ''
                        break
                    }
                    default {
                        $Translated = 'Straight rows of keys are easy to guess'
                        break
                    }
                }
                break
            }
            ([Warning]::ShortKeyboardPatterns) {
                switch ($Translation) {
                    ([Translation]::German) {
                        $Translated = ''
                        break
                    }
                    ([Translation]::Norwegian) {
                        $Translated = ''
                        break
                    }
                    default {
                        $Translated = 'Short keyboard patterns are easy to guess'
                        break
                    }
                }
                break
            }
            ([Warning]::RepeatsLikeAaaEasy) {
                switch ($Translation) {
                    ([Translation]::German) {
                        $Translated = ''
                        break
                    }
                    ([Translation]::Norwegian) {
                        $Translated = ''
                        break
                    }
                    default {
                        $Translated = 'Repeats like "aaa" are easy to guess'
                        break
                    }
                }
                break
            }
            ([Warning]::RepeatsLikeAbcSlighterHarder) {
                switch ($Translation) {
                    ([Translation]::German) {
                        $Translated = ''
                        break
                    }
                    ([Translation]::Norwegian) {
                        $Translated = ''
                        break
                    }
                    default {
                        $Translated = 'Repeats like "abcabcabc" are only slightly harder to guess than "abc"'
                        break
                    }
                }
                break
            }
            ([Warning]::SequenceAbcEasy) {
                switch ($Translation) {
                    ([Translation]::German) {
                        $Translated = ''
                        break
                    }
                    ([Translation]::Norwegian) {
                        $Translated = ''
                        break
                    }
                    default {
                        $Translated = 'Sequences like abc or 6543 are easy to guess'
                        break
                    }
                }
                break
            }
            ([Warning]::RecentYearsEasy) {
                switch ($Translation) {
                    ([Translation]::German) {
                        $Translated = ''
                        break
                    }
                    ([Translation]::Norwegian) {
                        $Translated = ''
                        break
                    }
                    default {
                        $Translated = 'Recent years are easy to guess'
                        break
                    }
                }
                break
            }
            ([Warning]::DatesEasy) {
                switch ($Translation) {
                    ([Translation]::German) {
                        $Translated = ''
                        break
                    }
                    ([Translation]::Norwegian) {
                        $Translated = ''
                        break
                    }
                    default {
                        $Translated = 'Dates are often easy to guess'
                        break
                    }
                }
                break
            }
            ([Warning]::Top10Passwords) {
                switch ($Translation) {
                    ([Translation]::German) {
                        $Translated = ''
                        break
                    }
                    ([Translation]::Norwegian) {
                        $Translated = ''
                        break
                    }
                    default {
                        $Translated = 'This is a top 10 common password'
                        break
                    }
                }
                break
            }
            ([Warning]::Top100Passwords) {
                switch ($Translation) {
                    ([Translation]::German) {
                        $Translated = ''
                        break
                    }
                    ([Translation]::Norwegian) {
                        $Translated = ''
                        break
                    }
                    default {
                        $Translated = 'This is a top 100 common password'
                        break
                    }
                }
                break
            }
            ([Warning]::CommonPasswords) {
                switch ($Translation) {
                    ([Translation]::German) {
                        $Translated = ''
                        break
                    }
                    ([Translation]::Norwegian) {
                        $Translated = ''
                        break
                    }
                    default {
                        $Translated = 'This is a very common password'
                        break
                    }
                }
                break
            }
            ([Warning]::WordEasy) {
                switch ($Translation) {
                    ([Translation]::German) {
                        $Translated = ''
                        break
                    }
                    ([Translation]::Norwegian) {
                        $Translated = ''
                        break
                    }
                    default {
                        $Translated = 'A word by itself is easy to guess'
                        break
                    }
                }
                break
            }
            ([Warning]::NameSurnamesEasy) {
                switch ($Translation) {
                    ([Translation]::German) {
                        $Translated = ''
                        break
                    }
                    ([Translation]::Norwegian) {
                        $Translated = ''
                        break
                    }
                    default {
                        $Translated = 'Names and surnames by themselves are easy to guess'
                        break
                    }
                }
                break
            }
            ([Warning]::CommonNameSurnamesEasy) {
                switch ($Translation) {
                    ([Translation]::German) {
                        $Translated = ''
                        break
                    }
                    ([Translation]::Norwegian) {
                        $Translated = ''
                        break
                    }
                    default {
                        $Translated = 'Common names and surnames are easy to guess'
                        break
                    }
                }
                break
            }
            ([Warning]::Empty) {
                switch ($Translation) {
                    ([Translation]::German) {
                        $Translated = ''
                        break
                    }
                    ([Translation]::Norwegian) {
                        $Translated = ''
                        break
                    }
                    default {
                        $Translated = ''
                        break
                    }
                }
                break
            }
            default {
                $Translated = ''
                break
            }
        }
        return $Translated
    }

    static [string]GetSuggestion([Suggestion]$Suggestion, [Translation]$Translation = [Translation]::English) {
        [string]$Translated = ''

        switch ($Suggestion) {
            ([Suggestion]::AddAnotherWordOrTwo) {
                switch ($Translation) {
                    ([Translation]::German) {
                        $Translated = ''
                        break
                    }
                    ([Translation]::Norwegian) {
                        $Translated = ''
                        break
                    }
                    default {
                        $Translated = 'Add another word or two. Uncommon words are better.'
                        break
                    }
                }
                break
            }
            ([Suggestion]::UseLongerKeyboardPattern) {
                switch ($Translation) {
                    ([Translation]::German) {
                        $Translated = ''
                        break
                    }
                    ([Translation]::Norwegian) {
                        $Translated = ''
                        break
                    }
                    default {
                        $Translated = 'Use a longer keyboard pattern with more turns'
                        break
                    }
                }
                break
            }
            ([Suggestion]::AvoidRepeatedWordsAndChars) {
                switch ($Translation) {
                    ([Translation]::German) {
                        $Translated = ''
                        break
                    }
                    ([Translation]::Norwegian) {
                        $Translated = ''
                        break
                    }
                    default {
                        $Translated = 'Avoid repeated words and characters'
                        break
                    }
                }
                break
            }
            ([Suggestion]::AvoidSequences) {
                switch ($Translation) {
                    ([Translation]::German) {
                        $Translated = ''
                        break
                    }
                    ([Translation]::Norwegian) {
                        $Translated = ''
                        break
                    }
                    default {
                        $Translated = 'Avoid sequences'
                        break
                    }
                }
                break
            }
            ([Suggestion]::AvoidYearsAssociatedYou) {
                switch ($Translation) {
                    ([Translation]::German) {
                        $Translated = ''
                        break
                    }
                    ([Translation]::Norwegian) {
                        $Translated = ''
                        break
                    }
                    default {
                        $Translated = 'Avoid recent years and avoid years that are associated with you'
                        break
                    }
                }
                break
            }
            ([Suggestion]::AvoidDatesYearsAssociatedYou) {
                switch ($Translation) {
                    ([Translation]::German) {
                        $Translated = ''
                        break
                    }
                    ([Translation]::Norwegian) {
                        $Translated = ''
                        break
                    }
                    default {
                        $Translated = 'Avoid dates and years that are associated with you'
                        break
                    }
                }
                break
            }
            ([Suggestion]::CapsDontHelp) {
                switch ($Translation) {
                    ([Translation]::German) {
                        $Translated = ''
                        break
                    }
                    ([Translation]::Norwegian) {
                        $Translated = ''
                        break
                    }
                    default {
                        $Translated = 'Capitalization does not help very much'
                        break
                    }
                }
                break
            }
            ([Suggestion]::AllCapsEasy) {
                switch ($Translation) {
                    ([Translation]::German) {
                        $Translated = ''
                        break
                    }
                    ([Translation]::Norwegian) {
                        $Translated = ''
                        break
                    }
                    default {
                        $Translated = 'All uppercase is almost as easy to guess as all lowercase'
                        break
                    }
                }
                break
            }
            ([Suggestion]::ReversedWordEasy) {
                switch ($Translation) {
                    ([Translation]::German) {
                        $Translated = ''
                        break
                    }
                    ([Translation]::Norwegian) {
                        $Translated = ''
                        break
                    }
                    default {
                        $Translated = 'Reversed words are not much harder to guess'
                        break
                    }
                }
                break
            }
            ([Suggestion]::PredictableSubstitutionsEasy) {
                switch ($Translation) {
                    ([Translation]::German) {
                        $Translated = ''
                        break
                    }
                    ([Translation]::Norwegian) {
                        $Translated = ''
                        break
                    }
                    default {
                        $Translated = 'Predictable substitutions like "@" instead of "a" do not help very much'
                        break
                    }
                }
                break
            }
            ([Suggestion]::Empty) {
                switch ($Translation) {
                    ([Translation]::German) {
                        $Translated = ''
                        break
                    }
                    ([Translation]::Norwegian) {
                        $Translated = ''
                        break
                    }
                    default {
                        $Translated = ''
                        break
                    }
                }
                break
            }
            default {
                $Translated = 'Use a few words, avoid common phrases. No need for symbols, digits, or uppercase letters.'
                break
            }
            
        }

        return $Translated
    }
}