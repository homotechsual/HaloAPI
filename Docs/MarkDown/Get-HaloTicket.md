---
external help file: HaloAPI-help.xml
Module Name: HaloAPI
online version:
schema: 2.0.0
---

# Get-HaloTicket

## SYNOPSIS
Gets tickets from the Halo API.

## SYNTAX

### Multi (Default)
```
Get-HaloTicket [-Paginate] [-PageSize <Int32>] [-PageNo <Int32>] [-Order <String>] [-OrderDesc] [-TicketIDOnly]
 [-ViewID <Int32>] [-ColumnsID <Int32>] [-IncludeColumns] [-IncludeSLAActionDate] [-IncludeSLATimer]
 [-IncludeTimeTaken] [-IncludeSupplier] [-IncludeRelease1] [-IncludeRelease2] [-IncludeRelease3]
 [-IncludeChildIDs] [-IncludeNextActivityDate] [-TicketAreaID <Int32>] [-ListID <Int32>] [-AgentID <Int32>]
 [-StatusID <Int32>] [-RequestTypeID <Int32>] [-SupplierID <Int32>] [-ClientID <Int32>] [-Site <Int32>]
 [-UserName <String>] [-UserID <Int32>] [-ReleaseID <Int32>] [-AssetID <Int32>] [-ITILRequestTypeID <Int32>]
 [-OpenOnly] [-ClosedOnly] [-UnlinkedOnly] [-ContractID <Int32>] [-WithAttachments] [-Team <Int32[]>]
 [-Agent <Int32[]>] [-Status <Int32[]>] [-RequestType <Int32[]>] [-ITILRequestType <Int32[]>]
 [-Category1 <Int32[]>] [-Category2 <Int32[]>] [-Category3 <Int32[]>] [-Category4 <Int32[]>] [-SLA <Int32[]>]
 [-Priority <Int32[]>] [-Products <Int32[]>] [-Flagged <Int32[]>] [-ExcludeThese <Int32[]>] [-Search <String>]
 [-SearchActions] [-DateSearch <String>] [-StartDate <String>] [-EndDate <String>] [-SearchUserName <String>]
 [-SearchSummary <String>] [-SearchDetails <String>] [-SearchReportedBy <String>] [-SearchVersion <String>]
 [-SearchRelease1 <String>] [-SearchRelease2 <String>] [-SearchRelease3 <String>] [-SearchReleaseNote <String>]
 [-SearchInventoryNumber <String>] [-SearchOppContactName <String>] [-SearchOppCompanyName <String>]
 [-FullObjects] [<CommonParameters>]
```

### Single
```
Get-HaloTicket -TicketID <Int64> [-TicketIDOnly] [-IncludeDetails] [-IncludeLastAction] [<CommonParameters>]
```

## DESCRIPTION
Retrieves tickets from the Halo API - supports a variety of filtering parameters.

## EXAMPLES

### Example 1
```powershell
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

### -Agent
Filter by the specified array of agent IDs.

```yaml
Type: Int32[]
Parameter Sets: Multi
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -AgentID
Filter by the specified agent.

```yaml
Type: Int32
Parameter Sets: Multi
Aliases: agent_id

Required: False
Position: Named
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -AssetID
Filter by the specified asset.

```yaml
Type: Int32
Parameter Sets: Multi
Aliases: asset_id

Required: False
Position: Named
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -Category1
Filter by the specified array of category 1 IDs.

```yaml
Type: Int32[]
Parameter Sets: Multi
Aliases: category_1

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Category2
Filter by the specified array of category 2 IDs.

```yaml
Type: Int32[]
Parameter Sets: Multi
Aliases: category_2

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Category3
Filter by the specified array of category 3 IDs.

```yaml
Type: Int32[]
Parameter Sets: Multi
Aliases: category_3

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Category4
Filter by the specified array of category 4 IDs.

```yaml
Type: Int32[]
Parameter Sets: Multi
Aliases: category_4

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ClientID
Filter by the specified client.

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

### -ClosedOnly
Return only closed tickets in the results.

```yaml
Type: SwitchParameter
Parameter Sets: Multi
Aliases: closed_only

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -ColumnsID
The ID of the column profile to use to control data returned in the results.

```yaml
Type: Int32
Parameter Sets: Multi
Aliases: columns_id

Required: False
Position: Named
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -ContractID
Filter by the specified contract ID.

```yaml
Type: Int32
Parameter Sets: Multi
Aliases: contract_id

Required: False
Position: Named
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -DateSearch
Which date field to search against.

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

### -EndDate
End date for use with the '-datesearch' parameter.

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

### -ExcludeThese
Exclude the specified array of ticket IDs.

```yaml
Type: Int32[]
Parameter Sets: Multi
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Flagged
Filter by the specified array of flagged ticket IDs.

```yaml
Type: Int32[]
Parameter Sets: Multi
Aliases:

Required: False
Position: Named
Default value: None
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

### -IncludeChildIDs
Include child ticket IDs in the results.

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

### -IncludeColumns
Include column details in the the results.

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

### -IncludeLastAction
Include the last action in the result.

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

### -IncludeNextActivityDate
Include next activity date in the results.

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

### -IncludeRelease1
Include release 1 details in the results.

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

### -IncludeRelease2
Include release 2 details in the results.

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

### -IncludeRelease3
Include release 3 details in the results.

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

### -IncludeSLAActionDate
Include SLA action date in the results.

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

### -IncludeSLATimer
Include SLA timer in the results.

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

### -IncludeSupplier
Include supplier details in the results.

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

### -IncludeTimeTaken
Include time taken in the results.

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

### -ITILRequestType
Filter by the specified array of ITIL request type IDs.

```yaml
Type: Int32[]
Parameter Sets: Multi
Aliases: itil_requesttype

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ITILRequestTypeID
Filter by the specified ITIL request type.

```yaml
Type: Int32
Parameter Sets: Multi
Aliases: itil_requesttype_id

Required: False
Position: Named
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -ListID
Filter by the specified list.

```yaml
Type: Int32
Parameter Sets: Multi
Aliases: list_id

Required: False
Position: Named
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -OpenOnly
Return only open tickets in the results.

```yaml
Type: SwitchParameter
Parameter Sets: Multi
Aliases: open_only

Required: False
Position: Named
Default value: False
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

### -Priority
Filter by the specified array of priority IDs.

```yaml
Type: Int32[]
Parameter Sets: Multi
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Products
Filter by the specified array of product IDs.

```yaml
Type: Int32[]
Parameter Sets: Multi
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ReleaseID
Filter by the specified release.

```yaml
Type: Int32
Parameter Sets: Multi
Aliases: release_id

Required: False
Position: Named
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -RequestType
Filter by the specified array of request type IDs.

```yaml
Type: Int32[]
Parameter Sets: Multi
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -RequestTypeID
Filter by the specified request type.

```yaml
Type: Int32
Parameter Sets: Multi
Aliases: requesttype_id

Required: False
Position: Named
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -Search
Return tickets matching the search term in the results.

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

### -SearchActions
Include actions when searching.

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

### -SearchDetails
Return tickets where the details matches the search term.

```yaml
Type: String
Parameter Sets: Multi
Aliases: search_details

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SearchInventoryNumber
Return tickets where the asset tag matches the search term.

```yaml
Type: String
Parameter Sets: Multi
Aliases: search_invenotry_number

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SearchOppCompanyName
Return tickets where the opportunity company name matches the search term.

```yaml
Type: String
Parameter Sets: Multi
Aliases: search_oppcompanyname

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SearchOppContactName
Return tickets where the opportunity contact name matches the search term.

```yaml
Type: String
Parameter Sets: Multi
Aliases: search_oppcontactname

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SearchRelease1
Return tickets where release 1 matches the search term.

```yaml
Type: String
Parameter Sets: Multi
Aliases: search_release1

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SearchRelease2
Return tickets where release 2 matches the search term.

```yaml
Type: String
Parameter Sets: Multi
Aliases: search_release2

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SearchRelease3
Return tickets where release 3 matches the search term.

```yaml
Type: String
Parameter Sets: Multi
Aliases: search_release3

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SearchReleaseNote
Return tickets where the release note matches the search term.

```yaml
Type: String
Parameter Sets: Multi
Aliases: search_releasenote

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SearchReportedBy
Return tickets where the reported by matches the search term.

```yaml
Type: String
Parameter Sets: Multi
Aliases: search_reportedby

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SearchSummary
Return tickets where the summary matches the search term.

```yaml
Type: String
Parameter Sets: Multi
Aliases: search_summary

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SearchUserName
Return tickets where the user name matches the search term.

```yaml
Type: String
Parameter Sets: Multi
Aliases: search_user_name

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SearchVersion
Return tickets where the software version matches the search term.

```yaml
Type: String
Parameter Sets: Multi
Aliases: search_version

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Site
Filter by the specified site.

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

### -SLA
Filter by the specified array of SLA IDs.

```yaml
Type: Int32[]
Parameter Sets: Multi
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -StartDate
Start date for use with the '-datesearch' parameter.

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

### -Status
Filter by the specified array of status IDs.

```yaml
Type: Int32[]
Parameter Sets: Multi
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -StatusID
Filter by the specified status.

```yaml
Type: Int32
Parameter Sets: Multi
Aliases: status_id

Required: False
Position: Named
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -SupplierID
Filter by the specified supplier.

```yaml
Type: Int32
Parameter Sets: Multi
Aliases: supplier_id

Required: False
Position: Named
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -Team
Filter by the specified array of team IDs.

```yaml
Type: Int32[]
Parameter Sets: Multi
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -TicketAreaID
Filter by the specified ticket area.

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

### -TicketID
Ticket ID

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

### -TicketIDOnly
Return only the 'ID' fields (Ticket ID, SLA ID, Status ID, Client ID, Client Name and Last Incoming Email date)

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

### -UnlinkedOnly
Return only unlinked tickets in the results.

```yaml
Type: SwitchParameter
Parameter Sets: Multi
Aliases: unlinked_only

Required: False
Position: Named
Default value: False
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

### -UserName
Filter by the specified user name.

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
The ID of the filter profile to use to filter results.

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

### -WithAttachments
Return only tickets with attachments in the results.

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
