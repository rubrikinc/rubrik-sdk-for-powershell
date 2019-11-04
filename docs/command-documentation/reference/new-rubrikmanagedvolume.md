---
external help file: Rubrik-help.xml
Module Name: Rubrik
online version: >-
  https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/New-RubrikManagedVolume
schema: 2.0.0
---

# New-RubrikManagedVolume

## SYNOPSIS

Creates a new Rubrik Managed Volume

## SYNTAX

```text
New-RubrikManagedVolume [-Name] <String> [-Channels] <Int32> [[-Subnet] <String>] [[-VolumeSize] <Int64>]
 [[-applicationTag] <String>] [[-exportConfig] <PSObject[]>] [[-Server] <String>] [[-api] <String>]
 [<CommonParameters>]
```

## DESCRIPTION

The New-RubrikManagedVolume cmdlet is used to create a new Managed Volume

## EXAMPLES

### EXAMPLE 1

```text
New-RubrikManagedVolume -Name foo -Channels 4 -VolumeSize 1073741824000
```

Creates a new managed volume named 'foo' with 4 channels and 1073741824000 bytes \(1TB\) in size

### EXAMPLE 2

```text
New-RubrikManagedVolume -Name foo -Channels 2 -VolumeSize (500 * 1GB) -Subnet 172.21.10.0/23
```

Creates a new managed volume named 'foo' with 2 channels, 536870912000 bytes \(500 GB\) in size, on the 172.21.10.0/23 subnet

### EXAMPLE 3

```text
New-RubrikManagedVolume -Name foo -Channels 2 -VolumeSize (500 * 1GB) -ApplicationTag "PostgreSql"
```

Creates a new managed volume named 'foo' with 2 channels, 536870912000 bytes \(500 GB\) in size, configured for PostreSQL backups Valid ApplicationTag values are 'Oracle', 'OracleIncremental', 'MsSql', 'SapHana', 'MySql', 'PostgreSql', and 'RecoverX'

## PARAMETERS

### -Name

Name of managed volume

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

### -Channels

Number of channels in the Managed Volume

```yaml
Type: Int32
Parameter Sets: (All)
Aliases: numChannels

Required: True
Position: 2
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -Subnet

Subnet Managed Volume is placed on

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -VolumeSize

Size of the Managed Volume in Bytes

```yaml
Type: Int64
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -applicationTag

Application whose data will be stored in managed volume

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

### -exportConfig

Export config, such as host hints and host name patterns

```yaml
Type: PSObject[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 6
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
Position: 7
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
Position: 8
Default value: $global:RubrikConnection.api
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about\_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

Written by Mike Fal Twitter: @Mike\_Fal GitHub: MikeFal

## RELATED LINKS

[https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/New-RubrikManagedVolume](https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/New-RubrikManagedVolume)

