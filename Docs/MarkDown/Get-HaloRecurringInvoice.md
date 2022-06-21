---
external help file: HaloAPI-help.xml
Module Name: HaloAPI
online version:
schema: 2.0.0
---

# Get-HaloRecurringInvoice

## SYNOPSIS
Gets recurring invoices from the Halo API.

## SYNTAX

### Multi (Default)
```
Get-HaloRecurringInvoice [-Count <Int32>] [-Search <String>] [-Paginate] [-PageSize <Int32>] [-PageNo <Int32>]
 [-OrderBy <String>] [-OrderByDesc] [-OrderBy2 <String>] [-OrderByDesc2] [-OrderBy3 <String>] [-OrderByDesc3]
 [-OrderBy4 <String>] [-OrderByDesc4] [-OrderBy5 <String>] [-OrderByDesc5] [-includeinactive]
 [-includeinvoices] [-includecredits] [-includeLines] [-TicketID <Int32>] [-ClientID <Int32>] [-SiteID <Int32>]
 [-UserID <Int32>] [-FullObjects] [<CommonParameters>]
```

### Single
```
Get-HaloRecurringInvoice -RecurringInvoiceID <Int64> [-includeDetails] [<CommonParameters>]
```

## DESCRIPTION
Retrieves recurring invoices from the Halo API - supports a variety of filtering parameters.

## EXAMPLES

### Example 1
```powershell
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

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
The number of invoices to return if not using pagination.

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

### -FullObjects
Parameter to return the complete objects.

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

### -includecredits
Include credit notes

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

### -includeDetails
Include invoice Details

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

### -includeinactive
Include inactive records

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

### -includeinvoices
Include invoices

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

### -includeLines
Include invoice lines

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

### -OrderBy
First field to order the results by.

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
Second field to order the results by.

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
Third field to order the results by.

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
Fourth field to order the results by.

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
Fifth field to order the results by.

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
Order results for the first field in descending order (respects the field choice in '-OrderBy')

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
Order results for the second field in descending order (respects the field choice in '-OrderBy2')

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
Order results for the third field in descending order (respects the field choice in '-OrderBy3')

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
Order results for the fourth field in descending order (respects the field choice in '-OrderBy4')

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
Order results for the fifth field in descending order (respects the field choice in '-OrderBy5')

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

### -RecurringInvoiceID
Invoice ID

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
Filter by the specified site ID.

```yaml
Type: Int32
Parameter Sets: Multi
Aliases: site_id

Required: False
Position: Named
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -TicketID
Filter by the specified ticket ID.

```yaml
Type: Int32
Parameter Sets: Multi
Aliases: ticket_id

Required: False
Position: Named
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -UserID
Filter by the specified user ID.

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### A powershell object containing the response.
## NOTES

## RELATED LINKS
