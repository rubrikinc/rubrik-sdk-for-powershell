#requires -Version 3
function Get-RubrikObject
{
  <#  
      .SYNOPSIS
      Retrieve summary information for all objects that are registered with a Rubrik cluster.

      .DESCRIPTION
      The Get-RubrikObject cmdlet is used to retrive information on one or more objects existing within the Rubrik cluster. Rubrik objects consist of any type of VM, Host, Fileset, NAS Share, cloud instance, etc.

      .NOTES
      Written by Mike Preston for community usage
      Twitter: @mwpreston
      GitHub: mwpreston

      .LINK
      http://rubrikinc.github.io/rubrik-sdk-for-powershell/reference/Get-RubrikObject.html

      .EXAMPLE
      Get-RubrikObject -NameFilter 'test*'
      This will return all known objects within the Rubrik cluster matching the given name pattern

      .EXAMPLE
      Get-RubrikObject -IDFilter '1111-2222-3333-*'
      This will return all known objects within the Rubrik cluster matching the given id pattern

      .EXAMPLE 
      Get-RubrikObject -NameFilter 'test*' -IncludeObjectClass VirtualMachines
      This will return all known Virtual Machines within the Rubrik cluster matching the given name pattern

      .EXAMPLE
      Get-RubrikObject -NameFilter 'test*' -ExcludeObjectClass Databases
      This will return all known objects within the Rubrik cluster except those related to databases matching the given name pattern

      .EXAMPLE
      Get-RubrikObject -NameFilter 'test*' -IncludeObjectType VMwareVM,OracleDB
      This will return all known VMware VMs and Oracle Databases within the Rubrik cluster matching the given name pattern

      .EXAMPLE
      Get-RubrikObject -NameFilter 'test*' -ExcludeObjectType NutanixVM,APIToken
      This will return all known objects within the Rubrik cluster except Nutanix VMs and API tokens matching the given name pattern
      #>

  [CmdletBinding()]
  Param(
    # Filter by Name
    [Parameter(Mandatory=$true,ParameterSetName='FilterByName')]
    [ValidateNotNullOrEmpty()] 
    [String]$NameFilter,
    #Filter by ID
    [Parameter(Mandatory=$true,ParameterSetName='FilterByID')]
    [ValidateNotNullOrEmpty()]    
    [String]$IdFilter, 
    # Filter Objects to include
    [ValidateSet("VMwareVM","NutanixVM","HyperVVM","MSSSQLDB","OracleDB","Fileset","VolumeGroup","ManagedVolume","SLADomain","PhysicalHost",
                 "NasShare","FilesetTemplate","AvailabilityGroup","DatabaseMount","Event","LDAPObject","LogShipping","ManagedVolumeExport",
                 "VMwareVMLiveMount","RubrikOrganization","Report","RubrikCluster","SQLInstance","vCenterServer","VMwareDatastore","VMwareHost")]
    [String[]]$IncludeObjectType, 
    # Filter Objects to exclude
    [ValidateSet("VMwareVM","NutanixVM","HyperVVM","MSSSQLDB","OracleDB","Fileset","VolumeGroup","ManagedVolume","SLADomain","PhysicalHost",
                 "NasShare","FilesetTemplate","AvailabilityGroup","DatabaseMount","Event","LDAPObject","LogShipping","ManagedVolumeExport",
                 "VMwareVMLiveMount","RubrikOrganization","Report","RubrikCluster","SQLInstance","vCenterServer","VMwareDatastore","VMwareHost")]
    [String[]]$ExcludeObjectType, 
    # Filter Object Classes to include
    [ValidateSet("VirtualMachines","Databases","FilesAndVolumes","AllProtectedObjects","InternalRubrikObjects")]
    [String[]]$IncludeObjectClass,
    # Filter Object Classes to exclude
    [ValidateSet("VirtualMachines","Databases","FilesAndVolumes","AllProtectedObjects","InternalRubrikObjects")]
    [String[]]$ExcludeObjectClass,
    # Rubrik server IP or FQDN
    [String]$Server = $global:RubrikConnection.server,
    # API version
    [String]$api = $global:RubrikConnection.api
  )

  Begin {

    # The Begin section is used to perform one-time loads of data necessary to carry out the function's purpose
    # If a command needs to be run with each iteration or pipeline input, place it in the Process section
    
    # Check to ensure that a session to the Rubrik cluster exists and load the needed header data for authentication
    Test-RubrikConnection
  
  }

  Process {

    # Hashtable containing information around each object type. Name must match ValidateSet in Include/ExcludeObjectType parameter
    $ObjectTypes =
    @{
        "VMwareVM"            = [pscustomobject]@{ associatedCmdlet = "Get-RubrikVM"; FriendlyName = "VMware VMs"; SupportsNameSearch = $true; SupportsIDSearch = $true; NameField = "Name"; ObjectClass = @("VirtualMachines","AllProtectedObjects") }
        "NutanixVM"           = [pscustomobject]@{ associatedCmdlet = "Get-RubrikNutanixVM"; FriendlyName = "Nutanix VMs"; SupportsNameSearch = $true; SupportsIDSearch = $true; NameField = "Name"; ObjectClass = @("VirtualMachines","AllProtectedObjects")  }
        "HyperVVM"            = [pscustomobject]@{ associatedCmdlet = "Get-RubrikHyperVVM"; FriendlyName = "HyperV VMs"; SupportsNameSearch = $true; SupportsIDSearch = $true; NameField = "Name"; ObjectClass = @("VirtualMachines","AllProtectedObjects") }
        "MSSQLDB"             = [pscustomobject]@{ associatedCmdlet = "Get-RubrikDatabase"; FriendlyName = "MSSQL DBs"; SupportsNameSearch = $true; SupportsIDSearch = $true; NameField = "Name"; ObjectClass = @("Databases","AllProtectedObjects") }
        "OracleDB"            = [pscustomobject]@{ associatedCmdlet = "Get-RubrikOracleDB"; FriendlyName = "Oracle DBs"; SupportsNameSearch = $true; SupportsIDSearch = $true; NameField = "Name"; ObjectClass = @("Databases","AllProtectedObjects")  }
        "Fileset"             = [pscustomobject]@{ associatedCmdlet = "Get-RubrikFileset"; FriendlyName = "Filesets"; SupportsNameSearch = $true; SupportsIDSearch = $true; NameField = "Name"; ObjectClass = @("FilesAndVolumes","AllProtectedObjects")  }
        "VolumeGroup"         = [pscustomobject]@{ associatedCmdlet = "Get-RubrikVolumeGroup"; FriendlyName = "Volume Groups"; SupportsNameSearch = $true; SupportsIDSearch = $true; NameField = "Name"; ObjectClass = @("FilesAndVolumes","AllProtectedObjects") }
        "ManagedVolume"       = [pscustomobject]@{ associatedCmdlet = "Get-RubrikManagedVolume"; FriendlyName = "Managed Volumes"; SupportsNameSearch = $true; SupportsIDSearch = $true; NameField = "Name"; ObjectClass = @("FilesAndVolumes","AllProtectedObjects") }
        "SLADomain"           = [pscustomobject]@{ associatedCmdlet = "Get-RubrikSLA"; FriendlyName = "SLA Domains"; SupportsNameSearch = $true; SupportsIDSearch = $true; NameField = "Name"; ObjectClass = "InternalRubrikObjects" }
        "PhysicalHost"        = [pscustomobject]@{ associatedCmdlet = "Get-RubrikHost"; FriendlyName = "Physical Hosts"; SupportsNameSearch = $true; SupportsIDSearch = $true; NameField = "Name"; ObjectClass = "FilesAndVolumes" }
        "NasShare"            = [pscustomobject]@{ associatedCmdlet = "Get-RubrikNasShare"; FriendlyName = "NAS Shares"; SupportsNameSearch = $true; SupportsIDSearch = $true; NameField = "ExportPoint"; ObjectClass = @("FilesAndVolumes","AllProtectedObjects") }
        "FilesetTemplate"     = [pscustomobject]@{ associatedCmdlet = "Get-RubrikFilesetTemplate"; FriendlyName = "Fileset Templates"; SupportsNameSearch = $true; SupportsIDSearch = $true; NameField = "Name"; ObjectClass = "FilesAndVolumes" }
        "AvailabilityGroup"   = [pscustomobject]@{ associatedCmdlet = "Get-RubrikAvailabilityGroup"; FriendlyName = "Availability Groups"; SupportsNameSearch = $true; SupportsIDSearch = $true; NameField = "Name"; ObjectClass = "Databases" }
        "DatabaseMount"       = [pscustomobject]@{ associatedCmdlet = "Get-RubrikDatabaseMount"; FriendlyName = "Database Mounts"; SupportsNameSearch = $true; SupportsIDSearch = $true; NameField = "mountedDatabaseName"; ObjectClass = "Databases" }
        "Event"               = [pscustomobject]@{ associatedCmdlet = "Get-RubrikEvent"; FriendlyName = "Events"; SupportsNameSearch = $true; SupportsIDSearch = $true; NameField = "objectName"; ObjectClass = "InternalRubrikObjects" }
        "LDAPObject"          = [pscustomobject]@{ associatedCmdlet = "Get-RubrikLDAP"; FriendlyName = "LDAP Objects"; SupportsNameSearch = $true; SupportsIDSearch = $true; NameField = "Name"; ObjectClass = "InternalRubrikObjects" }
        "LogShipping"         = [pscustomobject]@{ associatedCmdlet = "Get-RubrikLogShipping"; FriendlyName = "Log Shipping Targets"; SupportsNameSearch = $true; SupportsIDSearch = $true; NameField = "secondaryDatabaseName"; ObjectClass = "Databases" }
        "ManagedVolumeExport" = [pscustomobject]@{ associatedCmdlet = "Get-RubrikManagedVolumeExport"; FriendlyName = "Managed Volume Exports"; SupportsNameSearch = $false; SupportsIDSearch = $true; NameField = "Name"; ObjectClass = "FilesAndVolumes" }
        "VMwareVMLiveMount"   = [pscustomobject]@{ associatedCmdlet = "Get-RubrikMount"; FriendlyName = "VMware VM Live Mount"; SupportsNameSearch = $false; SupportsIDSearch = $true; NameField = "Name"; ObjectClass = "VirtualMachines" }
        "RubrikOrganization"  = [pscustomobject]@{ associatedCmdlet = "Get-RubrikOrganization"; FriendlyName = "Rubrik Organizations"; SupportsNameSearch = $true; SupportsIDSearch = $true; NameField = "Name"; ObjectClass = "InternalRubrikObjects" }
        "Report"              = [pscustomobject]@{ associatedCmdlet = "Get-RubrikReport"; FriendlyName = "Rubrik Reports"; SupportsNameSearch = $true; SupportsIDSearch = $true; NameField = "Name"; ObjectClass = "InternalRubrikObjects" }
        "RubrikCluster"       = [pscustomobject]@{ associatedCmdlet = "Get-RubrikSetting"; FriendlyName = "Rubrik Clusters"; SupportsNameSearch = $true; SupportsIDSearch = $true; NameField = "Name"; ObjectClass = "InternalRubrikObjects" }
        "SQLInstance"         = [pscustomobject]@{ associatedCmdlet = "Get-RubrikSQLInstance"; FriendlyName = "SQL Instances"; SupportsNameSearch = $true; SupportsIDSearch = $true; NameField = "Name"; ObjectClass = "Databases" }
        "vCenterServer"       = [pscustomobject]@{ associatedCmdlet = "Get-RubrikvCenter"; FriendlyName = "vCenter Servers"; SupportsNameSearch = $true; SupportsIDSearch = $true; NameField = "Name"; ObjectClass = "InternalRubrikObjects" }
        "VMwareDatastore"     = [pscustomobject]@{ associatedCmdlet = "Get-RubrikVMwareDatastore"; FriendlyName = "VMware Datastores"; SupportsNameSearch = $true; SupportsIDSearch = $true; NameField = "Name"; ObjectClass = "InternalRubrikObjects" }
        "VMwareHost"          = [pscustomobject]@{ associatedCmdlet = "Get-RubrikVMwareHost"; FriendlyName = "VMware Hosts"; SupportsNameSearch = $true; SupportsIDSearch = $true; NameField = "Name"; ObjectClass = "InternalRubrikObjects" }
        "APIToken"            = [pscustomobject]@{ associatedCmdlet = "Get-RubrikAPIToken"; FriendlyName = "API Tokens"; SupportsNameSearch = $true; SupportsIDSearch = $true; NameField = "Tag"; ObjectClass = "InternalRubrikObjects" }
    }

    # Create new variable to use in order to determine which objects to parse and assume all objects are being included
    $ObjectsToParse = [System.Collections.ArrayList]$ObjectTypes.Keys

    # If passed, shorten ObjectsToParse to only those in included specified classes
    If ($IncludeObjectClass) {
      $ObjectsToParse = [System.Collections.ArrayList]@()
      foreach ($ObjectClass in $IncludeObjectClass) {
          $ObjectTypes.GetEnumerator() | Where-Object {$_.Value.ObjectClass -contains "$ObjectClass"} | ForEach-Object {
            [void]$ObjectsToParse.Add($_.Name)
          }
      }
    }
     # If passed add any specified object types to ObjectsToParse
    If ($IncludeObjectType) { 
      foreach ($ObjectType in $IncludeObjectType) {
        [void]$ObjectsToParse.Add($ObjectType)
      } 
    }
    # If passed remove object types included in specified Object Classes
    if ($ExcludeObjectClass) {
      foreach ($ObjectClass in $ExcludeObjectClass) {
        $ObjectTypes.GetEnumerator() | Where-Object {$_.Value.ObjectClass -contains "$ObjectClass"} | ForEach-Object {
          [void]$ObjectsToParse.Remove($_.Name)
        } 
      }
    }
    # If passed, remove specifed object types from ObjectsToParse
    If ($ExcludeObjectType) {
      foreach ($ObjectType in $ExcludeObjectType) {
        $ObjectsToParse.Remove($ObjectType)
      }
    } 

    # retrieve and remove objects from ObjectsToParse not supporting name search
    if ($NameFilter) { 
      $ObjectTypes.GetEnumerator() | Where-Object {$_.Value.SupportsNameSearch -eq $false} | ForEach-Object {$ObjectsToParse.Remove($_.Name)}
    }
    # retrieve and remove objects from ObjectsToParse not supporting ID search
    if ($IdFilter) { 
      $ObjectTypes.GetEnumerator() | Where-Object {$_.Value.SupportsIdSearch -eq $false} | ForEach-Object {$ObjectsToParse.Remove($_.Name)}
    }

    # initialize counters for progress bar
    $TotalObjectTypes = $ObjectsToParse.Count
    $Completed = 0

    # Initialize Result
    $Result = @()

    # Parse individual objects
    ForEach ($ObjectType in $ObjectsToParse) {
      $completed += 1
      Write-Progress -Activity "Searching Rubrik Objects - Operation $completed out of $TotalObjectTypes - $($ObjectTypes[$ObjectType].FriendlyName)"
      if ($NameFilter) {
        $CmdletFilter = ' | where-object { $_.' + $ObjectTypes[$ObjectType].NameField + ' -like ' + "'$NameFilter' }"
      }
      if ($IDFilter) {
        $CmdletFilter = ' | where-object { $_.id -like ' + "'$IDFilter' }"
      }
      $SelectProperties = " | Select-Object -Property *, @{label='objectTypeMatch';expression={'"+$ObjectType+"'}}"
      $comm = $ObjectTypes[$ObjectType].associatedCmdlet + $CmdletFilter + $SelectProperties
      $Result += Invoke-Expression -Command $comm
    }
    Write-Progress -Activity "Searching Rubrik Objects - Completed" -Completed

    return $Result

  } # End of process
} # End of function