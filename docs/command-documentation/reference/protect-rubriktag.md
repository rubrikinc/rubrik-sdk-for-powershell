---
external help file: Rubrik-help.xml
Module Name: Rubrik
online version: https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/protect-rubriktag
schema: 2.0.0
---

# Protect-RubrikTag

## SYNOPSIS
Connects to Rubrik and assigns an SLA Domain based on a vSphere category and tag value

## SYNTAX

### SLA_Explicit
```
Protect-RubrikTag -Tag <String> -Category <String> [-SLA <String>] [-Server <String>] [-api <String>] [-WhatIf]
 [-Confirm] [<CommonParameters>]
```

### SLA_Unprotected
```
Protect-RubrikTag -Tag <String> -Category <String> [-DoNotProtect] [-Server <String>] [-api <String>] [-WhatIf]
 [-Confirm] [<CommonParameters>]
```

### SLA_Inherit
```
Protect-RubrikTag -Tag <String> -Category <String> [-Inherit] [-Server <String>] [-api <String>] [-WhatIf]
 [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
The Protect-RubrikTag cmdlet will update a virtual machine's SLA Domain assignment within the Rubrik cluster.
The SLA Domain contains all policy-driven values needed to protect workloads.
Make sure you have PowerCLI installed and connect to the required vCenter Server.

## EXAMPLES

### EXAMPLE 1
```
Protect-RubrikTag -Tag 'Gold' -Category 'Rubrik' -SLA 'Gold'
```

This will assign the Gold SLA Domain to any VM tagged with Gold in the Rubrik category

### EXAMPLE 2
```
Protect-RubrikTag -Tag 'Gold' -Category 'Rubrik' -SLA 'Titanium'
```

This will assign the Titanium SLA Domain to any VM tagged with Gold in the Rubrik category

### EXAMPLE 3
```
Protect-RubrikTag -Tag 'Gold' -Category 'Rubrik' -DoNotProtect
```

This will remove protection from any VM tagged with Gold in the Rubrik category

### EXAMPLE 4
```
Protect-RubrikTag -Tag 'Gold' -Category 'Rubrik' -Inherit
```

This will flag any VM tagged with Gold in the Rubrik category to inherit the SLA Domain of its parent object

## PARAMETERS

### -Tag
vSphere Tag

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

### -Category
vSphere Tag Category

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

### -SLA
The SLA Domain in Rubrik

```yaml
Type: String
Parameter Sets: SLA_Explicit
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -DoNotProtect
Removes the SLA Domain assignment

```yaml
Type: SwitchParameter
Parameter Sets: SLA_Unprotected
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Inherit
Inherits the SLA Domain assignment from a parent object

```yaml
Type: SwitchParameter
Parameter Sets: SLA_Inherit
Aliases:

Required: False
Position: Named
Default value: False
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
Position: Named
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
Position: Named
Default value: $global:RubrikConnection.api
Accept pipeline input: False
Accept wildcard characters: False
```

### -WhatIf
Shows what would happen if the cmdlet runs.
The cmdlet is not run.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: wi

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Confirm
Prompts you for confirmation before running the cmdlet.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: cf

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

## NOTES
Written by Jason Burrell for community usage
Twitter: @jasonburrell2

## RELATED LINKS

[https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/protect-rubriktag](https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/protect-rubriktag)

