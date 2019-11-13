class PasswordScoring {
    [string]$StartUpper = '^[A-Z][^A-Z]+$'
    [string]$EndUpper = '^[^A-Z]+[A-Z]$'
    [string]$AllUpper = '^[^a-z]+$'
    [string]$AllLower = '^[^A-Z]+$'

    static [int]PasswordCardinality([string]$Password) {
        $cl = 0

        if ($Password -cmatch '[a-z]') {
            $cl = $cl + 26
        }
        
        if ($Password -cmatch '[A-Z]') {
            $cl = $cl + 26
        }
        
        if ($Password -match '[0-9]') {
            $cl = $cl + 10
        }
        
        if (password.Any(c => c <= '/' || (':' <= c && c <= '@') || ('[' <= c && c <= '`') || ('{' <= c && c <= 0x7F))) cl += 33; // Symbols
        if ($Password -match '[!"#$%&()*+,./:;<=>?@\^_{|}]') {
            $cl = $cl + 33
        }
            if (password.Any(c => c > 0x7F)) cl += 100; // 'Unicode' (why 100?)

            return $cl
        }

        /// <summary>
        /// Calculate a rough estimate of crack time for entropy, see zxcbn scoring.coffee for more information on the model used
        /// </summary>
        /// <param name="entropy">Entropy of password</param>
        /// <returns>An estimation of seconts taken to crack password</returns>
        public static double EntropyToCrackTime(double entropy)
        {
            const double SingleGuess = 0.01;
            const double NumAttackers = 100;
            const double SecondsPerGuess = SingleGuess / NumAttackers;

            return 0.5 * Math.Pow(2, entropy) * SecondsPerGuess;
        }

        /// <summary>
        /// Return a score for password strength from the crack time. Scores are 0..4, 0 being minimum and 4 maximum strength.
        /// </summary>
        /// <param name="crackTimeSeconds">Number of seconds estimated for password cracking</param>
        /// <returns>Password strength. 0 to 4, 0 is minimum</returns>
        public static int CrackTimeToScore(double crackTimeSeconds)
        {
            if (crackTimeSeconds < Math.Pow(10, 2)) return 0;
            else if (crackTimeSeconds < Math.Pow(10, 4)) return 1;
            else if (crackTimeSeconds < Math.Pow(10, 6)) return 2;
            else if (crackTimeSeconds < Math.Pow(10, 8)) return 3;
            else return 4;
        }

        /// <summary>
        /// Caclulate binomial coefficient (i.e. nCk)
        /// Uses same algorithm as zxcvbn (cf. scoring.coffee), from http://blog.plover.com/math/choose.html 
        /// </summary>
        /// <param name="k">k</param>
        /// <param name="n">n</param>
        /// <returns>Binomial coefficient; nCk</returns>
        public static long Binomial(int n, int k)
        {
            if (k > n) return 0;
            if (k == 0) return 1;

            long r = 1;
            for (int d = 1; d <= k; ++d)
            {
                r *= n;
                r /= d;
                n -= 1;
            }

            return r;
        }

        /// <summary>
        /// Estimate the extra entropy in a token that comes from mixing upper and lowercase letters.
        /// This has been moved to a static function so that it can be used in multiple entropy calculations.
        /// </summary>
        /// <param name="word">The word to calculate uppercase entropy for</param>
        /// <returns>An estimation of the entropy gained from casing in <paramref name="word"/></returns>
        public static double CalculateUppercaseEntropy(string word)
        {

            if (Regex.IsMatch(word, AllLower)) return 0;

            // If the word is all uppercase add's only one bit of entropy, add only one bit for initial/end single cap only
            if (new[] { StartUpper, EndUpper, AllUpper }.Any(re => Regex.IsMatch(word, re))) return 1;

            var lowers = word.Where(c => 'a' <= c && c <= 'z').Count();
            var uppers = word.Where(c => 'A' <= c && c <= 'Z').Count();

            // Calculate numer of ways to capitalise (or inverse if there are fewer lowercase chars) and return lg for entropy
            return Math.Log(Enumerable.Range(0, Math.Min(uppers, lowers) + 1).Sum(i => PasswordScoring.Binomial(uppers + lowers, i)), 2);
        }
    }
