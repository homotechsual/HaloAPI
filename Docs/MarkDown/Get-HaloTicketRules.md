---
external help file: HaloAPI-help.xml
Module Name: HaloAPI
online version:
schema: 2.0.0
---

# Get-HaloTicketRules

## SYNOPSIS
Gets Halo Ticket Rules information from the Halo API.

## SYNTAX

### Multi (Default)
```
Get-HaloTicketRules [-ExcludeWorkflow] [-ShowAll] [<CommonParameters>]
```

### Single
```
Get-HaloTicketRules -RuleID <Int64> [-IncludeDetails] [-IncludeCriteriaInfo] [<CommonParameters>]
```

## DESCRIPTION
Retrieves Ticket Rule from the Halo API.
By default it retrieves global rules AND workflow step rules.
Use "-ExcludeWorkflow" to limit the list to only Global Rules.

## EXAMPLES

### Example 1
```powershell
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

### -RuleID
Rule ID

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

### -IncludeDetails
{{ Fill IncludeDetails Description }}

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

### -IncludeCriteriaInfo
{{ Fill IncludeCriteriaInfo Description }}

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

### -ExcludeWorkflow
Include Workflow Step Rules

```yaml
Type: SwitchParameter
Parameter Sets: Multi
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -ShowAll
ShowAll

```yaml
Type: SwitchParameter
Parameter Sets: Multi
Aliases:

Required: False
Position: Named
Default value: False
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
