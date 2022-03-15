---
external help file: HaloAPI-help.xml
Module Name: HaloAPI
online version:
schema: 2.0.0
---

# New-HaloGETRequest

## SYNOPSIS
Builds a request for the Halo API.

## SYNTAX

```
New-HaloGETRequest [-Method] <String> [-Resource] <String> [-RawResult] [[-QSCollection] <Hashtable>]
 [-AutoPaginateOff] [[-ResourceType] <String>] [<CommonParameters>]
```

## DESCRIPTION
Wrapper function to build web requests for the Halo API.

## EXAMPLES

### EXAMPLE 1
```
New-HaloGETRequest -Method "GET" -Resource "/api/Articles"
Gets all Knowledgebase Articles
```

## PARAMETERS

### -Method
The HTTP request method.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Resource
The resource to send the request to.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -RawResult
Returns the Raw result.
Useful for file downloads

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

### -QSCollection
A hashtable used to build the query string.

```yaml
Type: Hashtable
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -AutoPaginateOff
Disables auto pagination.

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

### -ResourceType
The key for the results object.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### Outputs an object containing the response from the web request.
## NOTES

## RELATED LINKS
