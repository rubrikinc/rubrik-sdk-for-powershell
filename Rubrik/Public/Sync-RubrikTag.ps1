#Requires -Version 3
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
      Sync-RubrikTag -Server 'vcenter1.demo' -Category 'Rubrik'
      This will validate or create a vSphere Category named Rubrik along with a Tag for each SLA Domain found in Rubrik
  #>

  [CmdletBinding()]
  Param(
    # The vSphere Category name for the Rubrik SLA Tags
    [Parameter(Mandatory = $true,Position = 0)]
    [ValidateNotNullorEmpty()]
    [String]$Category,
    # Rubrik server IP or FQDN
    [String]$Server = $global:RubrikConnection.server,
    # API version
    [String]$api = $global:RubrikConnection.api
  )

  Begin {

    Test-RubrikConnection
    Test-VMwareConnection
  
  }

  Process {
        
    Write-Verbose -Message 'Gather the SLA Domains'
    $sladomain = Get-RubrikSLA

    Write-Verbose -Message 'Validate the tag category exists'
    if (-not ((Get-TagCategory) -eq $Category)) 
    {
      New-TagCategory -Name $Category -Description 'Rubrik SLA Domains' -Cardinality Single -ErrorAction SilentlyContinue
    }
       
    Write-Verbose -Message 'Validate the tags exist'
    foreach ($_ in $sladomain)
    {
      Write-Verbose -Message "Creating $($_.name) tag"
      New-Tag -Name $_.name -Category $Category -ErrorAction SilentlyContinue
    }
        
    Write-Verbose -Message 'Create the DoNotProtect assignment for VMs without an SLA Domain'
    New-Tag -Name 'DoNotProtect' -Category $Category -ErrorAction SilentlyContinue

  } # End of process
} # End of function
