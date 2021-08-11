---
external help file: HaloAPI-help.xml
Module Name: HaloAPI
online version:
schema: 2.0.0
---

# Get-HaloSite

## SYNOPSIS
Gets sites from the Halo API.

## SYNTAX

### Multi (Default)
```
Get-HaloSite [-Paginate] [-PageSize <Int32>] [-PageNo <Int32>] [-Order <String>] [-OrderDesc]
 [-Search <String>] [-TopLevelID <Int32>] [-ClientID <Int32>] [-IncludeInactive] [-IncludeActive]
 [-Count <Int32>] [<CommonParameters>]
```

### Single
```
Get-HaloSite -SiteID <Int64> [<CommonParameters>]
```

## DESCRIPTION
Retrieves sites from the Halo API - supports a variety of filtering parameters.

## EXAMPLES

### No Examples

Thought of a useful example? Tell us or submit a PR.

## PARAMETERS

### -ClientID
Filter by the specified client ID.

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

### -Count
The number of sites to return if not using pagination.

```yaml
Type: Int32
Parameter Sets: Multi
Aliases:

Required: False
Position: Named
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -IncludeActive
Include active sites in the results.

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

### -IncludeInactive
Include inactive sites in the results.

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

### -Order
The field to order the results by.

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

### -OrderDesc
Order results in descending order (respects the field choice in '-Order')

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

### -Search
Return contracts matching the search term in the results.

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
Site ID

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

### -TopLevelID
Filter by the specified top level ID.

```yaml
Type: Int32
Parameter Sets: Multi
Aliases: toplevel_id

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

### A powershell object containing the response.
## NOTES

## RELATED LINKS
