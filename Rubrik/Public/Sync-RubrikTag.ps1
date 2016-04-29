#requires -Modules Rubrik
#requires -PSSnapin VMware.VimAutomation.Core
#Requires -Version 2
function Sync-RubrikTag
{
    <#  
            .SYNOPSIS
            Connects to Rubrik and creates a vSphere tag for each SLA Domain
            .DESCRIPTION
            The Sync-RubrikTag cmdlet will query Rubrik for all of the existing SLA Domains, and then create a tag for each one
            .NOTES
            Written by Chris Wahl for community usage
            Twitter: @ChrisWahl
            GitHub: chriswahl
            .LINK
            https://github.com/rubrikinc/PowerShell-Module
    #>

    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true,Position = 0,HelpMessage = 'vCenter FQDN or IP address')]
        [ValidateNotNullorEmpty()]
        [String]$vCenter,
        [Parameter(Mandatory = $false,Position = 1,HelpMessage = 'Rubrik FQDN or IP address')]
        [ValidateNotNullorEmpty()]
        [String]$Server = $global:RubrikConnection.server
    )

    Process {

        TestRubrikConnection

        ConnectTovCenter -vCenter $vCenter
        
        Write-Verbose -Message 'Gather the SLA Domains'
        $sladomain = Get-RubrikSLA

        Write-Verbose -Message 'Validate the tag category exists'
        $category_name = 'Rubrik_SLA'
        if (-not ((Get-TagCategory) -match $category_name)) 
        {
            New-TagCategory -Name $category_name -Description 'Rubrik SLA Domains' -Cardinality Single
        }
       
        Write-Verbose -Message 'Validate the tags exist'
        foreach ($_ in $sladomain)
        {
            New-Tag -Name $_.name -Category $category_name -ErrorAction SilentlyContinue
        }
        
        Write-Verbose -Message 'Create the Unprotected assignment for VMs without an SLA Domain'
        New-Tag -Name 'Unprotected' -Category $category_name -ErrorAction SilentlyContinue
        
        Write-Verbose -Message 'Submit the request to determine SLA Domain assignments to VMs'
        $vmlist = Get-RubrikVM -VM *
        
        Write-Verbose -Message 'Assign tags to the VMs that have SLA Domain assignments'
        foreach ($_ in $vmlist)
        {
            if ($_.effectiveSlaDomainName) 
            {
                New-TagAssignment -Tag (Get-Tag -Name $_.effectiveSlaDomainName) -Entity $_.name
            }
        }

    } # End of process
} # End of function