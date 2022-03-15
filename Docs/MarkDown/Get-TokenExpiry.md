---
external help file: HaloAPI-help.xml
Module Name: HaloAPI
online version:
schema: 2.0.0
---

# Get-TokenExpiry

## SYNOPSIS
Calculates and returns the expiry date/time of a Halo token.

## SYNTAX

```
Get-TokenExpiry [-ExpiresIn] <Int64> [<CommonParameters>]
```

## DESCRIPTION
Takes the expires in time for an auth token and returns a PowerShell date/time object containing the expiry date/time of the token.

## EXAMPLES

### Example 1
```powershell
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

### -ExpiresIn
Timestamp value for token expiry.
e.g 3600

```yaml
Type: Int64
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### A powershell date/time object representing the token expiry.
## NOTES

## RELATED LINKS
