---
external help file: HaloAPI-help.xml
Module Name: HaloAPI
online version:
schema: 2.0.0
---

# Get-HaloService

## SYNOPSIS

Gets services from the Halo API.

## SYNTAX

### Multi (Default)
```
Get-HaloService [-Count <Int64>] [-Search <String>] [-Paginate] [-PageSize <Int32>] [-PageNo <Int32>]
 [-Order <String>] [-OrderDesc] [-UserID <Int32>] [-ServiceStatusIDs <Int32[]>] [-ServiceCatalogueType <Int32>]
 [-ServiceCategoryIDs <Int32[]>] [-ITILTicketType <Int32>] [-IncludeStatusInfo] [<CommonParameters>]
```

### Single
```
Get-HaloService -ServiceID <Int64> [-IncludeDetails] [<CommonParameters>]
```

## DESCRIPTION

Retrieves services from the Halo API - supports a variety of filtering parameters.

## EXAMPLES

### No Examples

Thought of a useful example? Tell us or submit a PR.

## PARAMETERS

### -ServiceID

Service ID

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

### -Order

Which field to order results based on.

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

### -UserID

Filters by services accessible to the specified user.

```yaml
Type: Int32
Parameter Sets: Multi
Aliases: user_id

Required: False
Position: Named
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -ServiceStatusIDs

Filters by the specified array of operational status IDs.

```yaml
Type: Int32[]
Parameter Sets: Multi
Aliases: service_status_ids

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ServiceCatalogueType

Filters by the specified service catalogue.

```yaml
Type: Int32
Parameter Sets: Multi
Aliases: service_catalogue_type

Required: False
Position: Named
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -ServiceCategoryIDs

Filters by the specified array of service category IDs.

```yaml
Type: Int32[]
Parameter Sets: Multi
Aliases: service_category_ids

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ITILTicketType

Filters by the specified ITIL ticket type ID.

```yaml
Type: Int32
Parameter Sets: Multi
Aliases: itil_ticket_type

Required: False
Position: Named
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -IncludeStatusInfo

Include service status information in the result.

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
