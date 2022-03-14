---
external help file: HaloAPI-help.xml
Module Name: HaloAPI
online version:
schema: 2.0.0
---

# Get-HaloTeam

## SYNOPSIS

Gets teams from the Halo API.

## SYNTAX

### Multi (Default)
```
Get-HaloTeam [-Type <String>] [-IncludeAgentsForTeams <String>] [-MemberOnly] [-ShowCounts] [-Domain <String>]
 [-ViewID <Int32>] [-IncludeEnabled] [-IncludeDisabled] [-DepartmentID <Int32>] [<CommonParameters>]
```

### Single
```
Get-HaloTeam -TeamID <Int64> [-IncludeDetails] [<CommonParameters>]
```

## DESCRIPTION

Retrieves teams from the Halo API - supports a variety of filtering parameters.

## EXAMPLES

### No Examples

Thought of a useful example? Tell us or submit a PR.

## PARAMETERS

### -TeamID

Team ID

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

### -Type

Filter teams to a specific type: reqs = tickets, opps = opportunities and prjs = projects.

```yaml
Type: String
Parameter Sets: Multi
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -IncludeAgentsForTeams

Teams to return agents for in the results.
Comma separated string.

```yaml
Type: String
Parameter Sets: Multi
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -MemberOnly

Only include teams the current agent is a member of.

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

### -ShowCounts

Show the count of team tickets in the results.

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

### -Domain

Filter counts to a specific domain: reqs = tickets, opps = opportunities and prjs = projects.

```yaml
Type: String
Parameter Sets: Multi
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ViewID

Filter counts to a specific view ID.

```yaml
Type: Int32
Parameter Sets: Multi
Aliases: view_id

Required: False
Position: Named
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -IncludeEnabled

Include enabled teams (defaults to $True).

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

### -IncludeDisabled

Include disabled teams.

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

### -DepartmentID

Filter by the specified department ID.

```yaml
Type: Int32
Parameter Sets: Multi
Aliases: department_id

Required: False
Position: Named
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -IncludeDetails

Include extra objects in the result.

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### A powershell object containing the response

## NOTES

## RELATED LINKS
