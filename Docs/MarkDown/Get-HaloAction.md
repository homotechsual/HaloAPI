---
external help file: HaloAPI-help.xml
Module Name: HaloAPI
online version:
schema: 2.0.0
---

# Get-HaloAction

## SYNOPSIS
Gets actions from the Halo API.

## SYNTAX

### Multi (Default)
```
Get-HaloAction [-Count <Int64>] -TicketID <Int32> [-ExcludeSys] [-ConversationOnly] [-AgentOnly]
 [-SupplierOnly] [-ExcludePrivate] [-IncludeHTMLNote] [-IncludeHTMLEmail] [-IncludeAttachments]
 [-ImportantOnly] [-SLAOnly] [-IsChildNotes] [<CommonParameters>]
```

### Single
```
Get-HaloAction -ActionID <Int64> -TicketID <Int32> [-AgentOnly] [-IncludeEmail] [-IncludeDetails] [-MostRecent]
 [-EmailOnly] [-NonSystem] [<CommonParameters>]
```

## DESCRIPTION
Retrieves actions from the Halo API - supports a variety of filtering parameters.

## EXAMPLES

### Example 1
```powershell
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

### -ActionID
Action ID.

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

### -AgentOnly
Only get actions performed by agents.

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

### -ConversationOnly
Only get actions that are part of agent to end user conversations.

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

### -Count
The number of actions to return.

```yaml
Type: Int64
Parameter Sets: Multi
Aliases:

Required: False
Position: Named
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -EmailOnly
Only get email actions.

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

### -ExcludePrivate
Exclude private actions.

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

### -ExcludeSys
Exclude system-performed actions.

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

### -ImportantOnly
Only get important actions.

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

### -IncludeAttachments
Include attachment details in the response.

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

### -IncludeDetails
Include extra detail objects.

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

### -IncludeEmail
Include the HTML and plain text email body in the response.

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

### -IncludeHTMLEmail
Include the action email HTML in the response.

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

### -IncludeHTMLNote
Include the action note HTML in the response.

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

### -IsChildNotes
Only get actions from child tickets.

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

### -MostRecent
Ignore the '-ActionID' and get the most recent action for the '-TicketID'

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

### -NonSystem
Exclude system-performed actions.

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

### -SLAOnly
Only get SLA hold and release actions.

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

### -SupplierOnly
Only get actions that involve suppliers.

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

### -TicketID
Get actions for a single ticket with the specified ID.
\[HaloPipelineIDArgumentTransformation()\]

```yaml
Type: Int32
Parameter Sets: (All)
Aliases: ticket_id

Required: True
Position: Named
Default value: 0
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### A powershell object containing the response.
## NOTES

## RELATED LINKS
