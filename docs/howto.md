# How to use Passphraser

## Syntax

### New (Default)
```
New-Passphrase [[-AmountOfWords] <Int32>] [[-Separator] <Char>] [-IncludeNumbers] [[-AmountOfNumbers] <Int32>]
 [-IncludeUppercase] [-IncludeSpecials] [[-AmountOfSpecials] <Int32>] [-AsObject] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

### Custom
```
New-Passphrase [[-Separator] <Char>] [-IncludeNumbers] [[-AmountOfNumbers] <Int32>] [-IncludeUppercase]
 [-IncludeSpecials] [[-AmountOfSpecials] <Int32>] [-AsObject] -CustomString <String> [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

## Examples

### Example 1
```powershell
PS C:\> New-Passphrase
```
Generates a new all lowercase password with default values, 3 words and whitespace as separator.

### Example 2
```powershell
PS C:\> New-Passphrase -Separator "-"
```
Generates a new all lowercase password with 3 words and dash (-) as separator.

### Example 3
```powershell
PS C:\> New-Passphrase -AmountOfWords 5 -Separator "-" -IncludeNumbers -AmountOfNumbers 2 -IncludeUppercase
```
Generates a new password with 5 words, dash (-) as separator with 2 numbers and one uppercase word.

### Example 4
```powershell
PS C:\> New-Passphrase -AmountOfWords 5 -Separator "-" -IncludeNumbers -AmountOfNumbers 2 -IncludeUppercase -IncludeSpecials -AmountOfSpecials 2
```
Generates a new password with 5 words, dash (-) as separator with 2 numbers, 2 special characters and one uppercase word.

### Example 5
```powershell
PS C:\> New-Passphrase -AmountOfWords 5 -Separator "-" -IncludeNumbers -AmountOfNumbers 2 -IncludeUppercase -IncludeSpecials -AmountOfSpecials 2 | clip
```
Generates a new password with 5 words, dash (-) as separator with 2 numbers, 2 special characters, one uppercase word and pipes the string to "clip"

### Example 6
```powershell
PS C:\> New-Passphrase -AmountOfWords 5 -Separator "-" -IncludeNumbers -AmountOfNumbers 2 -IncludeUppercase -IncludeSpecials -AmountOfSpecials 2 -AsObject
```

Generates a new passphrase object with 5 words, dash (-) as separator with 2 numbers, 2 special characters and one uppercase word. This object can then be manipulated further.

### Example 7
```powershell
PS C:\> New-Passphrase -CustomString 'custom6 TEST !string' -Separator " " -AsObject
```

Generates a new passphrase object from custom string 'custom6 TEST !string' and outputs as an object. This object can then be manipulated further.

### Example 8
```powershell
PS C:\> 'custom6 TEST !string' | New-Passphrase -AsObject
```

CustomString accepts value from pipeline. This generates a new passphrase object from the value piped to New-Passphrase.

## Parameters

### -AmountOfNumbers
Amount of numbers to include

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: 1
Accept pipeline input: False
Accept wildcard characters: False
```

### -AmountOfSpecials
Amount of special characters to include

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: 1
Accept pipeline input: False
Accept wildcard characters: False
```

### -AmountOfWords
Amount of words to get

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 0
Default value: 3
Accept pipeline input: False
Accept wildcard characters: False
```

### -AsObject
Return passphrase as passphrase object

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Confirm
Prompts you for confirmation before running the cmdlet.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: cf

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -CustomString
Custom string to build passphrase object from

```yaml
Type: String
Parameter Sets: Custom
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -IncludeNumbers
Includes numbers

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -IncludeSpecials
Include special characters

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -IncludeUppercase
Include an uppercase word

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Separator
Separator to use between words

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: " " (whitespace)
Accept pipeline input: False
Accept wildcard characters: False
```

### -WhatIf
Shows what would happen if the cmdlet runs.
The cmdlet is not run.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: wi

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

### Inputs

#### None

### Outputs

#### System.String or PSObject
