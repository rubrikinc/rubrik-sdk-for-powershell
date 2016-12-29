Live Mount
========================

This page contains details on **Live Mount** commands.

Get-RubrikMount
------------------------

NAME
    Get-RubrikMount
    
SYNOPSIS
    Connects to Rubrik and retrieves details on mounts for a VM
    
    
SYNTAX
    Get-RubrikMount [[-VM] <String>] [[-MountID] <String>] [[-Server] <String>] [[-api] <String>] [<CommonParameters>]
    
    
DESCRIPTION
    The Get-RubrikMount cmdlet will accept a VM name and return details on any mount operations that are active within 
    Rubrik
    

PARAMETERS
    -VM <String>
        Virtual Machine to inspect for mounts
        
        Required?                    false
        Position?                    1
        Default value                
        Accept pipeline input?       true (ByPropertyName)
        Accept wildcard characters?  false
        
    -MountID <String>
        The Rubrik ID value of the mount
        
        Required?                    false
        Position?                    2
        Default value                
        Accept pipeline input?       true (ByPropertyName)
        Accept wildcard characters?  false
        
    -Server <String>
        Rubrik server IP or FQDN
        
        Required?                    false
        Position?                    3
        Default value                $global:RubrikConnection.server
        Accept pipeline input?       false
        Accept wildcard characters?  false
        
    -api <String>
        API version
        
        Required?                    false
        Position?                    4
        Default value                $global:RubrikConnection.api
        Accept pipeline input?       false
        Accept wildcard characters?  false
        
    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see 
        about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216). 
    
INPUTS
    
OUTPUTS
    
NOTES
    
    
        Written by Chris Wahl for community usage
        Twitter: @ChrisWahl
        GitHub: chriswahl
    
    -------------------------- EXAMPLE 1 --------------------------
    
    PS C:\>Get-RubrikMount
    
    Will return all Live Mounts known to Rubrik
    
    
    
    
    -------------------------- EXAMPLE 2 --------------------------
    
    PS C:\>Get-RubrikMount -VM Server1
    
    Will return all Live Mounts found for Server1
    
    
    
    
    -------------------------- EXAMPLE 3 --------------------------
    
    PS C:\>Get-RubrikMount -MountID 11111111-2222-3333-4444-555555555555
    
    Will return all Live Mounts found for the Rubrik ID 1234567890
    
    
    
    
    
RELATED LINKS
    https://github.com/rubrikinc/PowerShell-Module

New-RubrikMount
------------------------

NAME
    New-RubrikMount
    
SYNOPSIS
    Create a new Live Mount from a protected VM
    
    
SYNTAX
    New-RubrikMount [-VM] <String> [[-MountName] <String>] [[-Date] <String>] [[-PowerOn]] [[-Server] <String>] 
    [[-api] <String>] [-WhatIf] [-Confirm] [<CommonParameters>]
    
    
DESCRIPTION
    The New-RubrikMount cmdlet is used to create a Live Mount (clone) of a protected VM and run it in an existing 
    vSphere environment.
    

PARAMETERS
    -VM <String>
        Name of the virtual machine
        
        Required?                    true
        Position?                    1
        Default value                
        Accept pipeline input?       true (ByPropertyName)
        Accept wildcard characters?  false
        
    -MountName <String>
        An optional name for the Live Mount
        By default, will use the original VM name plus a date and instance number
        
        Required?                    false
        Position?                    2
        Default value                
        Accept pipeline input?       false
        Accept wildcard characters?  false
        
    -Date <String>
        Date of the snapshot to use for the Live Mount
        Format should match MM/DD/YY HH:MM
        If no value is specified, will retrieve the last known shapshot
        
        Required?                    false
        Position?                    3
        Default value                
        Accept pipeline input?       true (ByPropertyName)
        Accept wildcard characters?  false
        
    -PowerOn [<SwitchParameter>]
        Select the power state of the Live Mount
        Defaults to $false (powered off)
        
        Required?                    false
        Position?                    4
        Default value                False
        Accept pipeline input?       false
        Accept wildcard characters?  false
        
    -Server <String>
        Rubrik server IP or FQDN
        
        Required?                    false
        Position?                    5
        Default value                $global:RubrikConnection.server
        Accept pipeline input?       false
        Accept wildcard characters?  false
        
    -api <String>
        API version
        
        Required?                    false
        Position?                    6
        Default value                $global:RubrikConnection.api
        Accept pipeline input?       false
        Accept wildcard characters?  false
        
    -WhatIf [<SwitchParameter>]
        
        Required?                    false
        Position?                    named
        Default value                
        Accept pipeline input?       false
        Accept wildcard characters?  false
        
    -Confirm [<SwitchParameter>]
        
        Required?                    false
        Position?                    named
        Default value                
        Accept pipeline input?       false
        Accept wildcard characters?  false
        
    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see 
        about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216). 
    
INPUTS
    
OUTPUTS
    
NOTES
    
    
        Written by Chris Wahl for community usage
        Twitter: @ChrisWahl
        GitHub: chriswahl
    
    -------------------------- EXAMPLE 1 --------------------------
    
    PS C:\>New-RubrikMount -VM 'Server1' -Date '05/04/2015 08:00'
    
    This will create a new Live Mount for the virtual machine named Server1 based on the first snapshot that is equal 
    to or older than 08:00 AM on May 4th, 2015
    
    
    
    
    -------------------------- EXAMPLE 2 --------------------------
    
    PS C:\>New-RubrikMount -VM 'Server1'
    
    This will create a new Live Mount for the virtual machine named Server1 based on the first snapshot that is equal 
    to or older the current time (now)
    
    
    
    
    
RELATED LINKS
    https://github.com/rubrikinc/PowerShell-Module

Remove-RubrikMount
---------------------


NAME
    Remove-RubrikMount
    
SYNOPSIS
    Connects to Rubrik and removes one or more live mounts
    
    
SYNTAX
    Remove-RubrikMount [-MountID] <String> [[-Force]] [[-Server] <String>] [[-api] <String>] [-WhatIf] [-Confirm] 
    [<CommonParameters>]
    
    
DESCRIPTION
    The Remove-RubrikMount cmdlet is used to request the deletion of one or more instant mounts
    

PARAMETERS
    -MountID <String>
        The Rubrik ID value of the mount
        
        Required?                    true
        Position?                    1
        Default value                
        Accept pipeline input?       true (ByPropertyName)
        Accept wildcard characters?  false
        
    -Force [<SwitchParameter>]
        Force unmount to deal with situations where host has been moved
        
        Required?                    false
        Position?                    2
        Default value                False
        Accept pipeline input?       false
        Accept wildcard characters?  false
        
    -Server <String>
        Rubrik server IP or FQDN
        
        Required?                    false
        Position?                    3
        Default value                $global:RubrikConnection.server
        Accept pipeline input?       false
        Accept wildcard characters?  false
        
    -api <String>
        API version
        
        Required?                    false
        Position?                    4
        Default value                $global:RubrikConnection.api
        Accept pipeline input?       false
        Accept wildcard characters?  false
        
    -WhatIf [<SwitchParameter>]
        
        Required?                    false
        Position?                    named
        Default value                
        Accept pipeline input?       false
        Accept wildcard characters?  false
        
    -Confirm [<SwitchParameter>]
        
        Required?                    false
        Position?                    named
        Default value                
        Accept pipeline input?       false
        Accept wildcard characters?  false
        
    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see 
        about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216). 
    
INPUTS
    
OUTPUTS
    
NOTES
    
    
        Written by Chris Wahl for community usage
        Twitter: @ChrisWahl
        GitHub: chriswahl
    
    -------------------------- EXAMPLE 1 --------------------------
    
    PS C:\>Remove-RubrikMount -MountID 11111111-2222-3333-4444-555555555555
    
    This will a live mount with the ID of 11111111-2222-3333-4444-555555555555
    
    
    
    
    -------------------------- EXAMPLE 2 --------------------------
    
    PS C:\>Get-RubrikMount -VM Server1 | Remove-RubrikMount
    
    This will find and remove any live mount belonging to Server1
    
    
    
    
    
RELATED LINKS
    https://github.com/rubrikinc/PowerShell-Module



