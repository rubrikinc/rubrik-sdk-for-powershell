#Requires -Version 3
function Move-RubrikMountVMDK
{
  <#  
      .SYNOPSIS
      Moves the VMDKs from a Live Mount to another VM

      .DESCRIPTION
      The Move-RubrikMountVMDK cmdlet is used to attach VMDKs from a Live Mount to another VM, typically for restore or testing purposes.

      .NOTES
      Written by Chris Wahl for community usage
      Twitter: @ChrisWahl
      GitHub: chriswahl

      .LINK
      http://rubrikinc.github.io/rubrik-sdk-for-powershell/reference/Move-RubrikMountVMDK.html

      .EXAMPLE
      Move-RubrikMountVMDK -SourceVMID (Get-RubrikVM -Name 'SourceVM').id -TargetVM 'TargetVM'
      This will create a Live Mount using the latest snapshot of the VM named "SourceVM", using the VM's Rubrik ID.
      The Live Mount's VMDKs would then be presented to the VM named "TargetVM"

      .EXAMPLE
      Move-RubrikMountVMDK -SourceVM 'SourceVM' -TargetVM 'TargetVM'
      This will create a Live Mount using the latest snapshot of the VM named "SourceVM"
      The Live Mount's VMDKs would then be presented to the VM named "TargetVM"

      .EXAMPLE
      Move-RubrikMountVMDK -SourceVM 'SourceVM' -TargetVM 'TargetVM' -Date '01/30/2016 08:00'
      This will create a Live Mount using the January 30th 08:00AM snapshot of the VM named "SourceVM"
      The Live Mount's VMDKs would then be presented to the VM named "TargetVM"
      Note: The Date parameter will start at the time specified (in this case, 08:00am) and work backwards in time until it finds a snapshot.
      Precise timing is not required.
    
      .EXAMPLE
      Move-RubrikMountVMDK -SourceVM 'SourceVM' -TargetVM 'TargetVM' -ExcludeDisk @(0,1)
      This will create a Live Mount using the latest snapshot of the VM named "SourceVM"
      Disk 0 and 1 (the first and second disks) would be excluded from presentation to the VM named "TargetVM"
      Note: that for the "ExcludeDisk" array, the format is @(#,#,#,...) where each # represents a disk starting with 0.
      Example: To exclude the first and third disks, the value would be @(0,2).
      Example: To exclude just the first disk, use @(0).

      .EXAMPLE
      Move-RubrikMountVMDK -Cleanup 'C:\Users\Person1\Documents\SourceVM_to_TargetVM-1234567890.txt'
      This will remove the disk(s) and live mount, effectively reversing the initial request
      This file is created each time the command is run and stored in the $HOME path as a text file
      The file contains the TargetVM name, MountID value, and a list of all presented disks
  #>

  [CmdletBinding(SupportsShouldProcess = $true,ConfirmImpact = 'High')]
  Param(
    # Source virtual machine Rubrik ID to use as a live mount
    [Parameter(ParameterSetName = 'Create')]
    [String]$SourceVMID,
    # Source virtual machine to use as a Live Mount based on a previous backup
    [Parameter(ParameterSetName = 'Create')]
    [Alias('Name','VM')]
    [String]$SourceVM,
    # Target virtual machine to attach the Live Mount disk(s)
    [Parameter(Mandatory=$true,ParameterSetName = 'Create')]
    [String]$TargetVM,
    # Backup date to use for the Live Mount
    # Will use the current date and time if no value is specified
    [Parameter(ParameterSetName = 'Create')]
    [String]$Date,
    # An array of disks to exclude from presenting to the target virtual machine
    # By default, all disks will be presented
    [Parameter(ParameterSetName = 'Create')]
    [Array]$ExcludeDisk,
    # The path to a cleanup file to remove the live mount and presented disks
    # The cleanup file is created each time the command is run and stored in the $HOME path as a text file with a random number value
    # The file contains the TargetVM name, MountID value, and a list of all presented disks
    [Parameter(ParameterSetName = 'Destroy')]
    [String]$Cleanup,
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
    try{
    if (!$Cleanup)
    {
      if (!$Date) 
      {
        Write-Verbose -Message 'No date entered. Taking current time.'
        $Date = Get-Date
      }
      else {
        # Strip training Z from $Date. Using a date directly from an API response will cause PowerShell to create an inaccurate datetime object
        $Date = $Date.TrimEnd("Z")

        # Validate provided date
        try {
          $Date = [datetime]$Date
        }
        catch {
          throw "Invalid Date"
        }
      }

      Write-Verbose -Message "Validating Source and Target VMs"
      if($SourceVM -and !$SourceVMID){
        Write-Warning -Message "-SourceVM has been deprecated as a parameter. The code will attempt to match the correct Rubrik VM ID, but please use -SourceVMID."
        $SourceVMID = (Get-RubrikVM -Name $SourceVM -PrimaryClusterID local).id
        if(!$SourceVMID){
          throw "$SourceVM is invalid. Please use a valid VM."
        } elseif ($SourceVMID.Count -gt 1) {
          throw "$souceVM has mutliple results. Please use -SourceVMID to specific the VM you want to use."
        }
      }

      $HostID = (Get-RubrikVM -VM $TargetVM -PrimaryClusterID local).hostId
      if(!$HostID){
        throw "$targetvm is invalid."
      }
      Write-Verbose -Message "Creating a powered off Live Mount of $SourceVMID"
      $mount = Get-RubrikSnapshot -id $SourceVMID -Date $Date | New-RubrikMount -HostID $HostID
      
      if(-not $mount) {throw 'No mounts were created. Check that you have declared a valid VM.'}

      Write-Verbose -Message "Waiting for request $($mount.id) to complete"
      while ((Get-RubrikRequest -ID $mount.id -Type "vmware/vm").status -ne 'SUCCEEDED')
      {
        Start-Sleep -Seconds 5
      }
    
      Write-Verbose -Message 'Live Mount is now available'
      Write-Verbose -Message 'Gathering Live Mount ID value'

      foreach ($link in ((Get-RubrikRequest -ID $mount.id -Type "vmware/vm").links))
      {
        # There are two links - the request (self) and result
        # This will filter the values to just the result
        if ($link.rel -eq 'result')
        {
          # We just want the very last part of the link, which contains the ID value
          $MountID = $link.href.Split('/')[-1]
          Write-Verbose -Message "Found Live Mount ID $MountID"
        }
      }

      Write-Verbose -Message "Gathering details on Live Mount ID $MountID"
      $MountVM = Get-RubrikVM -id (Get-RubrikMount -id $MountID).mountedVmId
      
      Write-Verbose -Message 'Migrating the Mount VMDKs to VM'
      if ($PSCmdlet.ShouldProcess($TargetVM,'Migrating Live Mount VMDK(s)'))
      {
        [array]$MountVMdisk = Get-HardDisk $MountVM.name
        $MountedVMdiskFileNames = @()
        [int]$j = 0
        foreach ($_ in $MountVMdisk)
        {
          if ($ExcludeDisk -contains $j)
          {
            Write-Verbose -Message "Skipping Disk $j" -Verbose
          }
          else 
          {
            try
            {
              Remove-HardDisk -HardDisk $_ -DeletePermanently:$false -Confirm:$false | Out-Null
              New-HardDisk -VM $TargetVM -DiskPath $_.Filename | Out-Null
              $MountedVMdiskFileNames += $_.Filename
              Write-Verbose -Message "Migrated $($_.Filename) to $TargetVM"
            }
            catch
            {
              throw $_
            }
          }
          $j++
        }
      }

      $Diskfile = "$Home\Documents\"+$SourceVM+'_to_'+$TargetVM+'-'+(Get-Date).Ticks+'.txt'
      $TargetVM | Out-File -FilePath $Diskfile -Encoding utf8 -Force
      $MountID | Out-File -FilePath $Diskfile -Encoding utf8 -Append -Force      
      $MountedVMdiskFileNames | Out-File -FilePath $Diskfile -Encoding utf8 -Append -Force
      
      # Return information needed to cleanup the mounted disks and Live Mount
      $response = [pscustomobject]@{
        'Status' = 'Success'
        'CleanupFile' = $Diskfile
        'TargetVM' = $TargetVM
        'MountID' = $MountID
        'MountedVMdiskFileNames' = $MountedVMdiskFileNames
        'Example' = "Move-RubrikMountVMDK -Cleanup '$Diskfile'"
      }
      return $response
    }

    elseif ($Cleanup) 
    {
      if ((Test-Path $Cleanup) -ne $true) 
      {
        throw 'File does not exist'
      }
      $TargetVM = (Get-Content -Path $Cleanup -Encoding UTF8)[0]
      $MountID = (Get-Content -Path $Cleanup -Encoding UTF8)[1]
      $MountedVMdiskFileNames = (Get-Content -Path $Cleanup -Encoding UTF8) | Select-Object -Skip 2
      Write-Verbose -Message 'Removing disks from the VM'
      [array]$SourceVMdisk = Get-HardDisk $TargetVM
      foreach ($_ in $SourceVMdisk)
      {
        if ($MountedVMdiskFileNames -contains $_.Filename)
        {
          Write-Verbose -Message "Removing $_ from $TargetVM"
          Remove-HardDisk -HardDisk $_ -DeletePermanently:$false -Confirm:$false
        }
      }
        
      Write-Verbose -Message "Deleting the Live Mount named $($MountVM.name)"
      Remove-RubrikMount -id $MountID -Confirm:$false
    }
    } #end Try
    catch {
      #IF any error occurs, bail out of the script before any damage is done.
      throw $_
      break

    } #end Catch

  } # End of process
} # End of function
