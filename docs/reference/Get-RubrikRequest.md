---
external help file: Rubrik-help.xml
Module Name: Rubrik
online version: https://github.com/rubrikinc/PowerShell-Module
schema: 2.0.0
---

# Get-RubrikRequest

## SYNOPSIS
Connects to Rubrik and retrieves details on an async request

## SYNTAX

```
Get-RubrikRequest [-id] <String> [-Type] <String> [[-Server] <String>] [[-api] <String>]
```

## DESCRIPTION
The Get-RubrikRequest cmdlet will pull details on a request that was submitted to the distributed task framework.
This is helpful for tracking the state (success, failure, running, etc.) of a request.

## EXAMPLES

### -------------------------- EXAMPLE 1 --------------------------
```
Get-RubrikRequest -id 'MOUNT_SNAPSHOT_123456789:::0' -Type 'vmware/vm'
```

Will return details about an async VMware VM request named "MOUNT_SNAPSHOT_123456789:::0"

## PARAMETERS

### -id
ID of an asynchronous request

```yaml
Type: String
Parameter Sets: (All)
Aliases: 

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Type
The type of request

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

### -Server
Rubrik server IP or FQDN

```yaml
Type: String
Parameter Sets: (All)
Aliases: 

Required: False
Position: 3
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
Position: 4
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

