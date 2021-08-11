---
external help file: HaloAPI-help.xml
Module Name: HaloAPI
online version:
schema: 2.0.0
---

# Get-HaloAgent

## SYNOPSIS
Gets agents from the Halo API.

## SYNTAX

### Multi (Default)
```
Get-HaloAgent [-Team <String>] [-Search <String>] [-SectionID <Int32>] [-DepartmentID <Int32>]
 [-ClientID <Int32>] [-Role <String>] [-IncludeEnabled] [-IncludeDisabled] [-IncludeUnassigned] [-IncludeRoles]
 [<CommonParameters>]
```

### Me
```
Get-HaloAgent [-Me] [<CommonParameters>]
```

### Single
```
Get-HaloAgent -AgentID <Int64> [-IncludeDetails] [<CommonParameters>]
```

## DESCRIPTION
Retrieves agents from the Halo API - supports a variety of filtering parameters.

## EXAMPLES

### No Examples

Thought of a useful example? Tell us or submit a PR.

## PARAMETERS

### -AgentID
Agent ID.

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

### -ClientID
Filter by the specified client ID (agents who have access to this client).

```yaml
Type: Int32
Parameter Sets: Multi
Aliases: client_id

Required: False
Position: Named
Default value: 0
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
Include extra detail objects (for example teams and roles) in the response.

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

### -IncludeDisabled
Include agents with disabled accounts.

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

### -IncludeEnabled
Include agents with enabled accounts (defaults to $True).

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

### -IncludeRoles
Include the agent's roles list in the response.

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

### -IncludeUnassigned
Include the system unassigned agent account.

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

### -Me
Get the agent object for the access token owner

```yaml
Type: SwitchParameter
Parameter Sets: Me
Aliases:

Required: True
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Role
Filter by the specified role ID (requires int as string.)

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

### -Search
Filter by name, email address or telephone number using the specified search string.

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

### -SectionID
Filter by the specified team ID.
?ACT Query with Halo what this does!

```yaml
Type: Int32
Parameter Sets: Multi
Aliases: section_id

Required: False
Position: Named
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -Team
Filter by the specified team name.

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### A powershell object containing the response.
## NOTES

## RELATED LINKS
