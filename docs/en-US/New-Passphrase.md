---
external help file: Passphraser-help.xml
Module Name: Passphraser
online version:
schema: 2.0.0
---

# New-Passphrase

## SYNOPSIS
Generates a new random passphrase.

## SYNTAX

```
New-Passphrase [[-AmountOfWords] <Int32>] [[-Separator] <String>] [-IncludeNumbers]
 [[-AmountOfNumbers] <Int32>] [-IncludeUppercase] [-IncludeSpecials] [[-AmountOfSpecials] <Int32>] [-WhatIf]
 [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Generates a new random passphrase. Choose how many words, if you want to include an uppercase word, if you want to include numbers and/or special characters and how many of each.

## EXAMPLES

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

## PARAMETERS

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

## INPUTS

### None

## OUTPUTS

### System.String

## NOTES

## RELATED LINKS
