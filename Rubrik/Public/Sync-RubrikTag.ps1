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
            .EXAMPLE
            Sync-RubrikTag -vCenter 'vcenter1.demo' -Category 'Rubrik'
            This will validate or create a vSphere Category named Rubrik along with a Tag for each SLA Domain found in Rubrik
    #>

    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true,Position = 0,HelpMessage = 'vCenter FQDN or IP address')]
        [ValidateNotNullorEmpty()]
        [String]$vCenter,
        [Parameter(Mandatory = $true,Position = 1,HelpMessage = 'The vSphere Category name for the Rubrik SLA Tags')]
        [ValidateNotNullorEmpty()]
        [String]$Category,
        [Parameter(Mandatory = $false,Position = 2,HelpMessage = 'Rubrik FQDN or IP address')]
        [ValidateNotNullorEmpty()]
        [String]$Server = $global:RubrikConnection.server
    )

    Process {

        TestRubrikConnection

        ConnectTovCenter -vCenter $vCenter
        
        Write-Verbose -Message 'Gather the SLA Domains'
        $sladomain = Get-RubrikSLA

        Write-Verbose -Message 'Validate the tag category exists'
        if (-not ((Get-TagCategory) -eq $Category)) 
        {
            New-TagCategory -Name $Category -Description 'Rubrik SLA Domains' -Cardinality Single
        }
       
        Write-Verbose -Message 'Validate the tags exist'
        foreach ($_ in $sladomain)
        {
            New-Tag -Name $_.name -Category $Category -ErrorAction SilentlyContinue
        }
        
        Write-Verbose -Message 'Create the DoNotProtect assignment for VMs without an SLA Domain'
        New-Tag -Name 'DoNotProtect' -Category $Category -ErrorAction SilentlyContinue

    } # End of process
} # End of function