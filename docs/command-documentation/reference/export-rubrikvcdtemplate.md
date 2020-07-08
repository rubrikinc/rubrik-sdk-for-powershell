---
external help file: Rubrik-help.xml
Module Name: Rubrik
online version: https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/export-rubrikvcdtemplate
schema: 2.0.0
---

# Export-RubrikVCDTemplate

## SYNOPSIS
Exports a given vCD template

## SYNTAX

```
Export-RubrikVCDTemplate [[-id] <String>] [[-name] <String>] [[-catalogid] <String>] [[-orgvdcid] <String>]
 [[-storagePolicyId] <String>] [[-Server] <String>] [[-api] <String>] [<CommonParameters>]
```

## DESCRIPTION
The Export-RubrikVCDTemplate cmdlet exports the specified vCD template

## EXAMPLES

### EXAMPLE 1
```
Export-RubrikVCDTemplate -id '01234567-8910-1abc-d435-0abc1234d567' -Name 'Template-Export' -catalogid '01234567-8910-1abc-d435-0abc1234d567' -orgvdcid '01234567-8910-1abc-d435-0abc1234d567'
```

This exports the vCD Template snapshot with ID 01234567-8910-1abc-d435-0abc1234d567 to the vCD catalog with ID 01234567-8910-1abc-d435-0abc1234d567. 
The template will be exported to Org vDC ID with 01234567-8910-1abc-d435-0abc1234d567 temporarily, before being imported to the vCD catalog.
This should be an Org vDC in the same vCD Org where the target catalog exists.
Finding needed IDs can be done directly via API, or via a command similar to (Invoke-RubrikRESTCall -Endpoint 'vcd/hierarchy/VcdOrg:::01234567-8910-1abc-d435-0abc1234d567/children' -api 'internal' -Method GET).data

## PARAMETERS

### -id
Rubrik snapshot id of the vApp to export

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -name
Name of the newly exported vCD Template.
Defaults to \[TemplateName\]-Export

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -catalogid
ID of target catalog.
Defaults to the existing catalog.

```yaml
Type: String
Parameter Sets: (All)
Aliases: catalog_id

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -orgvdcid
Org vDC ID to export the vCD Template to.
This should be an Org vDC in the same vCD Org where the target catalog exists.

```yaml
Type: String
Parameter Sets: (All)
Aliases: org_vdc_id

Required: False
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -storagePolicyId
ID of the storage policy used to create the template.
Defaults to Org VDC settings.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 5
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Server
Rubrik server IP or FQDN

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 6
Default value: $global:RubrikConnection.server
Accept pipeline input: False
Accept wildcard characters: False
```

### -api
API version

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 7
Default value: $global:RubrikConnection.api
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
Written by Matt Elliott for community usage
Twitter: @NetworkBrouhaha
GitHub: shamsway

## RELATED LINKS

[https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/export-rubrikvcdtemplate](https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/export-rubrikvcdtemplate)

