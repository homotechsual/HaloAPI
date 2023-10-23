---
external help file: HaloAPI-help.xml
Module Name: HaloAPI
online version:
schema: 2.0.0
---

# Get-HaloCRMNote

## SYNOPSIS
Gets CRM notes from the Halo API.
https://mjcoltd.halopsa.com/api/CRMNote?count=15&client_id=29&includehtmlnote=true&includeattachments=true

## SYNTAX

### Multi (Default)
```
Get-HaloCRMNote [-Count <Int64>] -ClientID <Int32> [-IncludeHTMLNote] [-IncludeAttachments]
 [<CommonParameters>]
```

### Single
```
Get-HaloCRMNote -CRMNoteID <Int64> [-Count <Int64>] [-IncludeHTMLNote] [-IncludeAttachments]
 [<CommonParameters>]
```

## DESCRIPTION
Retrieves CRM notes from the Halo API - supports a variety of filtering parameters.

## EXAMPLES

### Example 1
```powershell
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

### -CRMNoteID
CRM note ID.

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
The number of CRM notes to return.

```yaml
Type: Int64
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -ClientID
Get CRM notes for a single client  with the specified ID.
\[HaloPipelineIDArgumentTransformation()\]

```yaml
Type: Int32
Parameter Sets: Multi
Aliases: client_id

Required: True
Position: Named
Default value: 0
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -IncludeHTMLNote
Include the CRM note HTML in the response.

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

### -IncludeAttachments
Include attachment details in the response.

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### A powershell object containing the response.
## NOTES

## RELATED LINKS
