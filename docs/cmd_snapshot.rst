Snapshot
========================

This page contains details on **Snapshot** commands.

Get-RubrikSnapshot
-------------------------

NAME
    Get-RubrikSnapshot
    
SYNOPSIS
    Retrieves all of the snapshots (backups) for a given virtual machine
    
    
SYNTAX
    Get-RubrikSnapshot [-VM] <String> [[-Server] <String>] [[-api] <String>] [<CommonParameters>]
    
    
DESCRIPTION
    The Get-RubrikSnapshot cmdlet is used to query the Rubrik cluster for all known snapshots (backups) for a 
    protected virtual machine
    

PARAMETERS
    -VM <String>
        Name of the virtual machine
        
        Required?                    true
        Position?                    1
        Default value                
        Accept pipeline input?       true (ByPropertyName)
        Accept wildcard characters?  false
        
    -Server <String>
        Rubrik server IP or FQDN
        
        Required?                    false
        Position?                    2
        Default value                $global:RubrikConnection.server
        Accept pipeline input?       false
        Accept wildcard characters?  false
        
    -api <String>
        API version
        
        Required?                    false
        Position?                    3
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
    
    PS C:\>Get-RubrikSnapshot -VM 'Server1'
    
    This will return an array of details for each snapshot (backup) for Server1
    
    
    
    
    
RELATED LINKS
    https://github.com/rubrikinc/PowerShell-Module

New-RubrikSnapshot
-----------------------------

NAME
    New-RubrikSnapshot
    
SYNOPSIS
    Takes a Rubrik snapshot of a virtual machine
    
    
SYNTAX
    New-RubrikSnapshot [-VM] <String> [[-Server] <String>] [[-api] <String>] [-WhatIf] [-Confirm] [<CommonParameters>]
    
    
DESCRIPTION
    The New-RubrikSnapshot cmdlet will trigger an on-demand snapshot for a specific virtual machine. This will be 
    taken by Rubrik and stored in the VM's chain of snapshots.
    

PARAMETERS
    -VM <String>
        Virtual machine name
        
        Required?                    true
        Position?                    1
        Default value                
        Accept pipeline input?       true (ByPropertyName)
        Accept wildcard characters?  false
        
    -Server <String>
        Rubrik server IP or FQDN
        
        Required?                    false
        Position?                    2
        Default value                $global:RubrikConnection.server
        Accept pipeline input?       false
        Accept wildcard characters?  false
        
    -api <String>
        API version
        
        Required?                    false
        Position?                    3
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
    
    PS C:\>New-RubrikSnapshot -VM 'Server1'
    
    This will trigger an on-demand backup for the virtual machine named Server1
    
    
    
    
    
RELATED LINKS
    https://github.com/rubrikinc/PowerShell-Module