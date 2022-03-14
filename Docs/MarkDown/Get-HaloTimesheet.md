---
external help file: HaloAPI-help.xml
Module Name: HaloAPI
online version:
schema: 2.0.0
---

# Get-HaloTimesheet

## SYNOPSIS

Gets timesheets from the Halo API.

## SYNTAX

```
Get-HaloTimesheet [-SelectedTeam <Int32>] [-ShowHolidays] [-SelectedAgents <Int32[]>]
 [-SelectedTypes <Int32[]>] [-StartDate <DateTime>] [-EndDate <DateTime>] [-ShowAllDates]
 [-IncludeTimesheetFields] [-UTCOffset <Int32>] [<CommonParameters>]
```

## DESCRIPTION

Retrieves timesheets from the Halo API - supports a variety of filtering parameters.

## EXAMPLES

### No Examples

Thought of a useful example? Tell us or submit a PR.

## PARAMETERS

### -SelectedTeam

Return the timesheet for the specified team.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -ShowHolidays

Include holidays in the result.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -SelectedAgents

Return the timesheet for the selected agents.

```yaml
Type: Int32[]
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SelectedTypes

Return the selected types.

```yaml
Type: Int32[]
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: @(0,1,2,3)
Accept pipeline input: False
Accept wildcard characters: False
```

### -StartDate

Timesheet start date/time.

```yaml
Type: DateTime
Parameter Sets: (All)
Aliases: start_date

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -EndDate

Timesheet end date/time.

```yaml
Type: DateTime
Parameter Sets: (All)
Aliases: end_date

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ShowAllDates

Include all days in the result.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -IncludeTimesheetFields

Include all timesheet fields in the result.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -UTCOffset

The UTC offset.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### A powershell object containing the response

## NOTES

## RELATED LINKS
