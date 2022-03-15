---
external help file: HaloAPI-help.xml
Module Name: HaloAPI
online version:
schema: 2.0.0
---

# Connect-HaloAPI

## SYNOPSIS
Creates a new connection to a Halo instance.

## SYNTAX

```
Connect-HaloAPI -URL <Uri> -ClientID <String> -ClientSecret <String> [-Scopes <String[]>] [-Tenant <String>]
 [<CommonParameters>]
```

## DESCRIPTION
Creates a new connection to a Halo instance and stores this in a PowerShell Session.

## EXAMPLES

### EXAMPLE 1
```
Connect-HaloAPI -URL "https://example.halopsa.com" -ClientId "c9534241-dde9-4d04-9d45-32b1fbff22ed" -ClientSecret "14c0c9af-2db1-48ab-b29c-51975df4afa2-739e4ef2-9aad-4fe9-b486-794feca48ea8" -Scopes "all" -Tenant "demo"
This logs into Halo using the Client Credentials authorisation flow.
```

## PARAMETERS

### -URL
The URL of the Halo instance to connect to.

```yaml
Type: Uri
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ClientID
The Client ID for the application configured in Halo.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ClientSecret
The Client Secret for the application configured in Halo.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Scopes
The API scopes to request, if this isn't passed the scope is assumed to be "all".
Pass a string or array of strings.
Limited by the scopes granted to the application in Halo.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: All
Accept pipeline input: False
Accept wildcard characters: False
```

### -Tenant
The tenant name required for hosted Halo instances.

```yaml
Type: String
Parameter Sets: (All)
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

### Sets two script-scoped variables to hold connection and authentication information.
## NOTES

## RELATED LINKS
