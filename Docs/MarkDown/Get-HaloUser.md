---
external help file: HaloAPI-help.xml
Module Name: haloapi
online version:
schema: 2.0.0
---

# Get-HaloUser

## SYNOPSIS
Gets users from the Halo API.

## SYNTAX

### Multi (Default)
```
Get-HaloUser [-Paginate] [-PageSize <Int32>] [-PageNo <Int32>] [-Order <String>] [-OrderDesc]
 [-Search <String>] [-SearchPhoneNumbers] [-TopLevelID <Int32>] [-ClientID <Int32>] [-SiteID <Int32>]
 [-OrganisationID <Int32>] [-DepartmentID <Int32>] [-AssetID <Int32>] [-IncludeActive] [-IncludeInactive]
 [-ApproversOnly] [-ExcludeAgents] [-Count <Int32>] [-FullObjects] [<CommonParameters>]
```

### Single
```
Get-HaloUser -UserID <Int64> [-IncludeDetails] [-IncludeActivity] [-IncludePopups] [<CommonParameters>]
```

## DESCRIPTION
Retrieves users from the Halo API - supports a variety of filtering parameters.

## EXAMPLES

### No Examples

Thought of a useful example? Tell us or submit a PR.

## PARAMETERS

### -ApproversOnly
Include approvers only in the results.

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

### -AssetID
Filter by the specified asset ID.

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
The number of users to return if not using pagination.

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

### -ExcludeAgents
Exclude users linked to agent accounts from the results.

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

### -FullObjects
Parameter to return the full objects.

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

### -IncludeActive
Include active users in the results.

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

### -IncludeActivity
Include ticket activity in the result.

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

### -IncludeInactive
Include inactive users in the results.

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

### -IncludePopups
Include customer popups in the result.

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

### -OrganisationID
Filter by the specified organisation ID.

```yaml
Type: Int32
Parameter Sets: Multi
Aliases: organisation_id

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
Return users matching the search term in the results.

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

### -SearchPhoneNumbers
Search on phone numbers when searching.

```yaml
Type: SwitchParameter
Parameter Sets: Multi
Aliases: search_phonenumbers

Required: False
Position: Named
Default value: False
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

### -UserID
User ID

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### A powershell object containing the response.
## NOTES

## RELATED LINKS
