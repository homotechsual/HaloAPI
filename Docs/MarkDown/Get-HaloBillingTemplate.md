---
external help file: HaloAPI-help.xml
Module Name: HaloAPI
online version:
schema: 2.0.0
---

# Get-HaloBillingTemplate

## SYNOPSIS
Gets billing templates from the Halo API.

## SYNTAX

### Multi (Default)
```
Get-HaloBillingTemplate [-ShowAll] [<CommonParameters>]
```

### Single
```
Get-HaloBillingTemplate -TemplateID <Int64> [-IncludeDetails] [<CommonParameters>]
```

## DESCRIPTION
Retrieves billing templates from the Halo API - supports a variety of filtering parameters.

## EXAMPLES

### Example 1
```powershell
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

### -IncludeDetails
Include details in results

```yaml
Type: SwitchParameter
Parameter Sets: Single
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -ShowAll
Show all results

```yaml
Type: SwitchParameter
Parameter Sets: Multi
Aliases: show_all

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -TemplateID
Template ID

```yaml
Type: Int64
Parameter Sets: Single
Aliases:

Required: True
Position: Named
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### A powershell object containing the response.
## NOTES

## RELATED LINKS
