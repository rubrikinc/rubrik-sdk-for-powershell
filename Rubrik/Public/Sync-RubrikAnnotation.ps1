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
      http://rubrikinc.github.io/rubrik-sdk-for-powershell/reference/Sync-RubrikAnnotation.html

      .EXAMPLE
      Sync-RubrikAnnotation
      This will find all VMs being protected with any Rubrik SLA Domain Name and update their SLA and snapshot count annotations
      using the defaults of "Rubrik_SLA" and "Rubrik_Backups" respectively.

      .EXAMPLE
      Sync-RubrikAnnotation -SLA Silver
      This will find all VMs being protected with a Rubrik SLA Domain Name of "Silver" and update their SLA and snapshot count annotations
      using the defaults of "Rubrik_SLA" and "Rubrik_Backups" respectively.

      .EXAMPLE
      Sync-RubrikAnnotation -SLAAnnotationName 'Backup-Policy' -BackupAnnotationName 'Backup-Snapshots' -LatestRubrikBackupAnnotationName 'Latest-Rubrik-Backup'
      This will find all VMs being protected with any Rubrik SLA Domain Name and update their SLA and snapshot count annotations
      using the custom values of "Backup-Policy", "Backup-Snapshots", and 'Latest-Rubrik-Backup' respectively.
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
    # Attribute name in vCenter for latest backup date
    # By default, will use "Rubrik_Latest_Backup"
    [Parameter(Position = 3)]
    [ValidateNotNullorEmpty()]
    [ValidateLength(1,63)]
    [String]$LatestRubrikBackupAnnotationName = 'Rubrik_Latest_Backup',
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

    Write-Verbose -Message "Ensuring vCenter has attributes for $SLAAnnotationName and $BackupAnnotationName"
    New-CustomAttribute -Name $SLAAnnotationName -TargetType VirtualMachine -ErrorAction SilentlyContinue | Out-Null
    New-CustomAttribute -Name $BackupAnnotationName -TargetType VirtualMachine -ErrorAction SilentlyContinue | Out-Null
    New-CustomAttribute -Name $LatestRubrikBackupAnnotationName -TargetType VirtualMachine -ErrorAction SilentlyContinue | Out-Null

    Write-Verbose -Message 'Updating vCenter annotations'
    foreach ($_ in (Get-RubrikVM -SLA $SLA -DetailedObject)) {
      Set-Annotation -Entity (Get-VM -Id ('VirtualMachine-'+$_.moid)) -CustomAttribute $SLAAnnotationName -Value $_.effectiveSlaDomainName | Out-Null
      Set-Annotation -Entity (Get-VM -Id ('VirtualMachine-'+$_.moid)) -CustomAttribute $BackupAnnotationName -Value $_.snapshotCount | Out-Null
      Set-Annotation -Entity (Get-VM -Id ('VirtualMachine-'+$_.moid)) -CustomAttribute $LatestRubrikBackupAnnotationName -Value ($_.snapshots | Sort-Object -Property date -Descending | Select -First 1).date | Out-Null
      Write-Verbose -Message "Successfully tagged $($_.name) as $($_.effectiveSlaDomainName)"
    }

  } # End of process
} # End of function