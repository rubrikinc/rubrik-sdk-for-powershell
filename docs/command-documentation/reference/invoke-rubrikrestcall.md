---
external help file: Rubrik-help.xml
Module Name: Rubrik
online version: https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/invoke-rubrikrestcall
schema: 2.0.0
---

# Invoke-RubrikRESTCall

## SYNOPSIS
Provides generic interface to make Rubrik REST API calls

## SYNTAX

```
Invoke-RubrikRESTCall [-Endpoint] <String> [-Method] <String> [[-Query] <PSObject>] [[-Body] <PSObject>]
 [-BodyAsArray] [[-Server] <String>] [[-api] <String>] [<CommonParameters>]
```

## DESCRIPTION
The Invoke-RubrikRESTCall allows users to make raw API endpoint calls to the Rubrik REST interface.
The user
will need to manage the format of both the endpoint call(including resource ids) and body, but provides the
option to make cmdlet independent API calls for automating Rubrik actions through PowerShell.
The Rubrik API
reference is found on the Rubrik device at:
  \<Rubrik IP\>/docs/v1
  \<Rubrik IP\>/docs/v1/playground

## EXAMPLES

### EXAMPLE 1
```
Invoke-RubrikRESTCall -Endpoint 'vmware/vm' -Method GET
```

Retrieve the raw output for all VMWare VMs being managed by the Rubrik device.

### EXAMPLE 2
```
Invoke-RubrikRESTCall -Endpoint 'vmware/vm' -Method GET -Query @{'name'='msf-sql2016'}
```

Retrieve the raw output for the VMWare VM msf-sql2016 using a query parameter.

### EXAMPLE 3
```
$body = New-Object -TypeName PSObject -Property @{'slaID'='INHERIT';'ForceFullSnapshot'='FALSE'}
```

Invoke-RubrikRESTCall -Endpoint 'vmware/vm/VirtualMachine:::fbcb1f51-9520-4227-a68c-6fe145982f48-vm-649/snapshot' -Method POST -Body $body

Execute an on-demand snapshot for the VMWare VM where the id is part of the endpoint.

### EXAMPLE 4
```
$body = New-Object -TypeName PSObject -Property @{'isPassthrough'=$true;'shareId'='HostShare:::11111';'templateId'='FilesetTemplate:::22222'}
```

Invoke-RubrikRESTCall -Endpoint 'fileset_template/bulk' -Method POST -Body $body -BodyAsArray

Creates a new fileset from the given fileset template and the given host id supporting Direct Archive. 
Since fileset_template/bulk expects an array, we force the single item array with the BodyAsArray parameter.

### EXAMPLE 5
```
Invoke-RubrikRESTCall -api internal -Endpoint nutanix/cluster/NutanixCluster:::d34d42c0-5468-4c37-a3cf-4376baf018e4/refresh -Method post
```

Refreshes the information of the Nutanix cluster

## PARAMETERS

### -Endpoint
Rubrik API endpoint, DO NOT USE LEADING '/'

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

### -Method
REST API method

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

### -Query
Hash table body to pass to API call

```yaml
Type: PSObject
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Body
Hash table body to pass to API call

```yaml
Type: PSObject
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -BodyAsArray
Force the body as an array (For endpoints requiring single item arrays)

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

### -Server
Rubrik server IP or FQDN

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 5
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
Position: 6
Default value: $global:RubrikConnection.api
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
Written by Matt Altimar & Mike Fal for community usage
Twitter: @Mike_Fal
GitHub: mikefal

## RELATED LINKS

[https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/invoke-rubrikrestcall](https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/invoke-rubrikrestcall)

