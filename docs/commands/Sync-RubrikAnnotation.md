---
external help file: Rubrik-help.xml
Module Name: Rubrik
online version: https://github.com/rubrikinc/PowerShell-Module
schema: 2.0.0
---

# Sync-RubrikAnnotation

## SYNOPSIS
Applies Rubrik SLA Domain information to VM Annotations using the Custom Attributes feature in vCenter

## SYNTAX

```
Sync-RubrikAnnotation [[-SLA] <String>] [[-SLAAnnotationName] <String>] [[-BackupAnnotationName] <String>]
 [-Server <String>] [-api <String>]
```

## DESCRIPTION
The Sync-RubrikAnnotation cmdlet will comb through all VMs currently being protected by Rubrik.
It will then create Custom Attribute buckets for SLA Domain Name(s) and Snapshot counts and assign details for each VM found in vCenter using Annotations.
The attribute names can be specified using this function's parameters or left as the defaults.
See the examples for more information.
Keep in mind that this only displays in the VMware vSphere Thick (C#) client, which is deprecated moving forward.

## EXAMPLES

### -------------------------- EXAMPLE 1 --------------------------
```
Sync-RubrikAnnotation
```

This will find all VMs being protected with any Rubrik SLA Domain Name and update their SLA and snapshot count annotations
using the defaults of "Rubrik_SLA" and "Rubrik_Backups" respectively.

### -------------------------- EXAMPLE 2 --------------------------
```
Sync-RubrikAnnotation -SLA Silver
```

This will find all VMs being protected with a Rubrik SLA Domain Name of "Silver" and update their SLA and snapshot count annotations
using the defaults of "Rubrik_SLA" and "Rubrik_Backups" respectively.

### -------------------------- EXAMPLE 3 --------------------------
```
Sync-RubrikAnnotation -SLAAnnotationName 'Backup-Policy' -BackupAnnotationName 'Backup-Snapshots'
```

This will find all VMs being protected with any Rubrik SLA Domain Name and update their SLA and snapshot count annotations
using the custom values of "Backup-Policy" and "Backup-Snapshots" respectively.

## PARAMETERS

### -SLA
Optional filter for a single SLA Domain Name
By default, all SLA Domain Names will be collected when this parameter is not used

```yaml
Type: String
Parameter Sets: (All)
Aliases: 

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SLAAnnotationName
Attribute name in vCenter for the Rubrik SLA Domain Name
By default, will use "Rubrik_SLA"

```yaml
Type: String
Parameter Sets: (All)
Aliases: 

Required: False
Position: 2
Default value: Rubrik_SLA
Accept pipeline input: False
Accept wildcard characters: False
```

### -BackupAnnotationName
Attribute name in vCenter for quantity of snapshots
By default, will use "Rubrik_Backups"

```yaml
Type: String
Parameter Sets: (All)
Aliases: 

Required: False
Position: 3
Default value: Rubrik_Backups
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

## INPUTS

## OUTPUTS

## NOTES
Written by Chris Wahl for community usage
Twitter: @ChrisWahl
GitHub: chriswahl

## RELATED LINKS

[https://github.com/rubrikinc/PowerShell-Module](https://github.com/rubrikinc/PowerShell-Module)

