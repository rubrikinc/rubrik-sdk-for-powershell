Invoke Commands
=========================

This page contains details on **Invoke** commands.

Invoke-RubrikRESTCall
-------------------------


NAME
    Invoke-RubrikRESTCall
    
SYNOPSIS
    Provides generic interface to make Rubrik REST API calls
    
    
SYNTAX
    Invoke-RubrikRESTCall [-Endpoint] <String> [-Method] <String> [[-Query] <PSObject>] [[-Body] <PSObject>] [[-Server] <String>] [[-api] <String>] [<CommonParameters>]
    
    
DESCRIPTION
    The Invoke-RubrikRESTCall allows users to make raw API endpoint calls to the Rubrik REST interface. The user
    will need to manage the format of both the endpoint call(including resource ids) and body, but provides the
    option to make cmdlet independent API calls for automating Rubrik actions through PowerShell. The Rubrik API
    reference is found on the Rubrik device at:
      <Rubrik IP>/docs/v1
      <Rubrik IP>/docs/v1/playground
    

PARAMETERS
    -Endpoint <String>
        Rubrik API endpoint, DO NOT USE LEADING '/'
        
    -Method <String>
        REST API method
        
    -Query <PSObject>
        Hash table body to pass to API call
        
    -Body <PSObject>
        Hash table body to pass to API call
        
    -Server <String>
        Rubrik server IP or FQDN
        
    -api <String>
        API version
        
    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see 
        about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216). 
    
    -------------------------- EXAMPLE 1 --------------------------
    
    PS C:\>Invoke-RubrikRESTCall -Endpoint 'vmware/vm' -Method GET
    
    Retrieve the raw output for all VMWare VMs being managed by the Rubrik device.
    
    
    
    
    -------------------------- EXAMPLE 2 --------------------------
    
    PS C:\>Invoke-RubrikRESTCall -Endpoint 'vmware/vm' -Method GET -Query (New-Object -TypeName PSObject -Property @{'name'='msf-sql2016'})
    
    Retrieve the raw output for the VMWare VM msf-sql2016 using a query parameter.
    
    
    
    
    -------------------------- EXAMPLE 3 --------------------------
    
    PS C:\>$body = New-Object -TypeName PSObject -Property @{'slaID'='INHERIT';'ForceFullSnapshot'='FALSE'}
    
    Invoke-RubrikRESTCall -Endpoint 'vmware/vm/VirtualMachine:::fbcb1f51-9520-4227-a68c-6fe145982f48-vm-649/snapshot' -Method POST -Body $body
    
    Execute an on-demand snapshot for the VMWare VM where the id is part of the endpoint.
    
    
    
    
REMARKS
    To see the examples, type: "get-help Invoke-RubrikRESTCall -examples".
    For more information, type: "get-help Invoke-RubrikRESTCall -detailed".
    For technical information, type: "get-help Invoke-RubrikRESTCall -full".
    For online help, type: "get-help Invoke-RubrikRESTCall -online"




