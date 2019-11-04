---
external help file: Rubrik-help.xml
Module Name: Rubrik
online version: 'https://github.com/nshores/rubrik-sdk-for-powershell/tree/bootstrap'
schema: 2.0.0
---

# New-RubrikBootStrap

## New-RubrikBootStrap

### SYNOPSIS

Send a Rubrik Bootstrap Request

### SYNTAX

```text
New-RubrikBootStrap [[-id] <String>] [[-Server] <String>] [-adminUserInfo] <Object> [-nodeConfigs] <Object>
 [[-enableSoftwareEncryptionAtRest] <Boolean>] [[-name] <String>] [[-ntpServerConfigs] <Object>]
 [[-dnsNameservers] <String[]>] [[-dnsSearchDomains] <String[]>] [<CommonParameters>]
```

### DESCRIPTION

This will send a bootstrap request

### EXAMPLES

#### EXAMPLE 1

```text
https://gist.github.com/nshores/104f069570740ea645d67a8aeab19759
```

New-RubrikBootStrap -Server 169.254.11.25 -name 'rubrik-edge' -dnsNameservers @\('192.168.11.1'\) -dnsSearchDomains @\('corp.us','branch.corp.us'\) -ntpserverconfigs @\(@{server = 'pool.ntp.org'}\) -adminUserInfo @{emailAddress = 'nick@shoresmedia.com'; id ='admin'; password = 'P@SSw0rd!'} -nodeconfigs @{node1 = @{managementIpConfig = @{address = '192.168.11.1'; gateway = '192.168.11.100'; netmask = '255.255.255.0'}}}

#### EXAMPLE 2

```text
$BootStrapHash = @{
```

Server = 169.254.11.25 name = 'rubrik-edge' dnsNameservers = @\('192.168.11.1'\) dnsSearchDomains = @\('corp.us','branch.corp.us'\) ntpserverconfigs = @\(@{server = 'pool.ntp.org'}\) adminUserInfo = @{emailAddress = 'nick@shoresmedia.com'; id ='admin'; password = 'P@SSw0rd!'} nodeconfigs = @{node1 = @{managementIpConfig = @{address = '192.168.11.1'; gateway = '192.168.11.100'; netmask = '255.255.255.0'}}} }

New-RubrikBootStrap @BootStrapHash

### PARAMETERS

#### -id

ID of the Rubrik cluster or me for self

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: Me
Accept pipeline input: False
Accept wildcard characters: False
```

#### -Server

Rubrik server IP or FQDN

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

#### -adminUserInfo

Admin User Info Hashtable

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: True
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

#### -nodeConfigs

Node Configuration Hashtable

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: True
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

#### -enableSoftwareEncryptionAtRest

Software Encryption

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: 5
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

#### -name

Cluster/Edge Name

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 6
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

#### -ntpServerConfigs

NTP Servers

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: 7
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

#### -dnsNameservers

DNS Servers

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 8
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

#### -dnsSearchDomains

DNS Search Domains

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 9
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

#### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about\_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

### INPUTS

### OUTPUTS

### NOTES

## DNS Param must be an array even if only passing a single server

## NTP Must be an array than contains hash table for each server object

## Nodeconfigs Param must be a hash table object.

### RELATED LINKS

[https://github.com/nshores/rubrik-sdk-for-powershell/tree/bootstrap](https://github.com/nshores/rubrik-sdk-for-powershell/tree/bootstrap)

