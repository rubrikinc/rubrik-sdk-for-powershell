#Requires -Version 3
function Sync-RubrikAnnotation
{
  <#  
      .SYNOPSIS
      Applies Rubrik SLA Domain information to VM Annotations using the Custom Attributes feature in vCenter

      .DESCRIPTION
      The Sync-RubrikAnnotation cmdlet will comb through all VMs currently being protected by Rubrik.
      It will then create Custom Attribute buckets for SLA Domain Name(s) and Snapshot counts and assign details for each VM found in vCenter using Annotations.
      The attribute names can be specified using this function's parameters or left as the defaults. See the examples for more information.
      Keep in mind that this only displays in the VMware vSphere Thick (C#) client, which is deprecated moving forward.

      .NOTES
      Written by Chris Wahl for community usage
      Twitter: @ChrisWahl
      GitHub: chriswahl

      .LINK
      https://github.com/rubrikinc/PowerShell-Module

      .EXAMPLE
      Sync-RubrikAnnotation
      This will find all VMs being protected with any Rubrik SLA Domain Name and update their SLA and snapshot count annotations
      using the defaults of "Rubrik_SLA" and "Rubrik_Backups" respectively.

      .EXAMPLE
      Sync-RubrikAnnotation -SLA Silver
      This will find all VMs being protected with a Rubrik SLA Domain Name of "Silver" and update their SLA and snapshot count annotations
      using the defaults of "Rubrik_SLA" and "Rubrik_Backups" respectively.

      .EXAMPLE
      Sync-RubrikAnnotation -SLAAnnotationName 'Backup-Policy' -BackupAnnotationName 'Backup-Snapshots'
      This will find all VMs being protected with any Rubrik SLA Domain Name and update their SLA and snapshot count annotations
      using the custom values of "Backup-Policy" and "Backup-Snapshots" respectively.
  #>

  [CmdletBinding()]
  Param(
    # Optional filter for a single SLA Domain Name
    # By default, all SLA Domain Names will be collected when this parameter is not used
    [Parameter(Position = 0)]
    [ValidateNotNullorEmpty()]
    [String]$SLA,
    # Attribute name in vCenter for the Rubrik SLA Domain Name
    # By default, will use "Rubrik_SLA"
    [Parameter(Position = 1)]
    [ValidateNotNullorEmpty()]
    [ValidateLength(1,63)]
    [String]$SLAAnnotationName = 'Rubrik_SLA',
    # Attribute name in vCenter for quantity of snapshots
    # By default, will use "Rubrik_Backups"
    [Parameter(Position = 2)]
    [ValidateNotNullorEmpty()]
    [ValidateLength(1,63)]
    [String]$BackupAnnotationName = 'Rubrik_Backups',
    # Rubrik server IP or FQDN
    [String]$Server = $global:RubrikConnection.server,
    # API version
    [String]$api = $global:RubrikConnection.api
  )

  Process {

    TestRubrikConnection
        
    ConnectTovCenter -vCenter $vCenter

    Write-Verbose -Message "Ensuring vCenter has attributes for $SLAAnnotationName and $BackupAnnotationName"
    New-CustomAttribute -Name $SLAAnnotationName -TargetType VirtualMachine -ErrorAction SilentlyContinue
    New-CustomAttribute -Name $BackupAnnotationName -TargetType VirtualMachine

    Write-Verbose -Message 'Updating vCenter annotations'
    foreach ($_ in (Get-RubrikVM -SLA $SLA))
    {
      $null = Set-Annotation -Entity (Get-VM -Id ('VirtualMachine-'+$_.moid)) -CustomAttribute $SLAAnnotationName -Value $_.effectiveSlaDomainName
      $null = Set-Annotation -Entity (Get-VM -Id ('VirtualMachine-'+$_.moid)) -CustomAttribute $BackupAnnotationName -Value $_.snapshotCount
      Write-Verbose -Message "Successfully tagged $($_.name) as $($_.effectiveSlaDomainName)"
    }

  } # End of process
} # End of function