SLA Domain
========================

This page contains details on **SLA Domain** commands.

Get-RubrikSLA
------------------------

NAME
    Get-RubrikSLA
    
SYNOPSIS
    Connects to Rubrik and retrieves details on SLA Domain(s)
    
    
SYNTAX
    Get-RubrikSLA [[-SLA] <String>] [[-Server] <String>] [[-api] <String>] [<CommonParameters>]
    
    
DESCRIPTION
    The Get-RubrikSLA cmdlet will query the Rubrik API for details on all available SLA Domains. Information on each
    domain will be reported to the console.
    

PARAMETERS
    -SLA <String>
        SLA Domain Name
        
        Required?                    false
        Position?                    1
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
    
    PS C:\>Get-RubrikSLA
    
    Will return all known SLA Domains
    
    
    
    
    -------------------------- EXAMPLE 2 --------------------------
    
    PS C:\>Get-RubrikSLA -SLA 'Gold'
    
    Will return details on the SLA Domain named Gold
    
    
    
    
    
RELATED LINKS
    https://github.com/rubrikinc/PowerShell-Module

Remove-RubrikSLA
---------------------------

NAME
    Remove-RubrikSLA
    
SYNOPSIS
    Connects to Rubrik and removes SLA Domains
    
    
SYNTAX
    Remove-RubrikSLA [[-id] <String>] [[-Server] <String>] [[-api] <String>] [-WhatIf] [-Confirm] [<CommonParameters>]
    
    
DESCRIPTION
    The Remove-RubrikSLA cmdlet will request that the Rubrik API delete an SLA Domain. The SLA Domain must have zero 
    protected VMs in order to be successful.
    

PARAMETERS
    -id <String>
        SLA Domain id
        
        Required?                    false
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
    
    PS C:\>Get-RubrikSLA -SLA 'Gold' | Remove-RubrikSLA
    
    This will attempt to remove the Gold SLA Domain from Rubrik if there are no VMs being protected by the policy
    
    
    
    
    
RELATED LINKS
    https://github.com/rubrikinc/PowerShell-Module