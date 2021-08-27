---
external help file: HaloAPI-help.xml
Module Name: HaloAPI
online version:
schema: 2.0.0
---

# Get-HaloQuote

## SYNOPSIS

Gets quotes from the Halo API.

## SYNTAX

### Multi (Default)

```powershell
Get-HaloQuote [-Count <Int64>] [-Search <String>] [-Paginate] [-PageSize <Int32>] [-PageNo <Int32>]
 [-OrderBy <String>] [-OrderByDesc] [-OrderBy2 <String>] [-OrderByDesc2] [-OrderBy3 <String>] [-OrderByDesc3]
 [-OrderBy4 <String>] [-OrderByDesc4] [-OrderBy5 <String>] [-OrderByDesc5] [-TicketID <Int64>]
 [-ClientID <Int64>] [-SiteID <Int64>] [-UserID <Int64>] [<CommonParameters>]
```

### Single

```powershell
Get-HaloQuote -QuoteID <Int64> [-IncludeDetails] [<CommonParameters>]
```

## DESCRIPTION

Retrieves quotes from the Halo API - supports a variety of filtering parameters.

## EXAMPLES

### No Examples

Thought of a useful example? Tell us or submit a PR.

## PARAMETERS

### -ClientID

Filters by the specified client

```yaml
Type: Int64
Parameter Sets: Multi
Aliases: client_id

Required: False
Position: Named
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -Count

Number of records to return

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

### -OrderBy

The name of the first field to order by

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

### -OrderBy2

The name of the second field to order by

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

### -OrderBy3

The name of the third field to order by

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

### -OrderBy4

The name of the fourth field to order by

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

### -OrderBy5

The name of the fifth field to order by

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

### -OrderByDesc

Whether to order ascending or descending

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

### -OrderByDesc2

Whether to order ascending or descending

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

### -OrderByDesc3

Whether to order ascending or descending

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

### -OrderByDesc4

Whether to order ascending or descending

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

### -OrderByDesc5

Whether to order ascending or descending

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

### -PageNo

Which page to return.

```yaml
Type: Int32
Parameter Sets: Multi
Aliases: page_no

Required: False
Position: Named
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -PageSize

Number of results per page.

```yaml
Type: Int32
Parameter Sets: Multi
Aliases: page_size

Required: False
Position: Named
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -Paginate

Paginate results

```yaml
Type: SwitchParameter
Parameter Sets: Multi
Aliases: pageinate

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -QuoteID

Quote ID

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

### -Search

Filters response based on the search string

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

### -SiteID

Filters by the specified site

```yaml
Type: Int64
Parameter Sets: Multi
Aliases: site_id

Required: False
Position: Named
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -TicketID

Filters by the specified ticket

```yaml
Type: Int64
Parameter Sets: Multi
Aliases: ticket_id

Required: False
Position: Named
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -UserID

Filters by the specified user

```yaml
Type: Int64
Parameter Sets: Multi
Aliases: user_id

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
