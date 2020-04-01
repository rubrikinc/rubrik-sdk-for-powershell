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
    https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/get-rubrikobject

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
    [ValidateSet("VMwareVM","NutanixVM","HyperVVM","MSSQLDB","OracleDB","Fileset","VolumeGroup","ManagedVolume","SLADomain","PhysicalHost",
                 "NasShare","FilesetTemplate","AvailabilityGroup","DatabaseMount","Event","EventSeries","LDAPObject","LogShipping","ManagedVolumeExport",
                 "VMwareVMLiveMount","RubrikOrganization","Report","RubrikCluster","SQLInstance","vCenterServer","VMwareDatastore","VMwareHost",
                 "VMwareDatacenter", "VMwareCluster","APIToken","Archive","RubrikCluster", "RubrikClusterNetwork", "RubrikNode", "GuestOSCredential","ReplicationSource","ReplicationTarget",
                 "SCVMMServer","SyslogServer","RubrikUser","VCDvApp","VCDServer","HyperVHost","NTPServer","NotificationSetting","NutanixCluster","SMBDomain")]
    [String[]]$IncludeObjectType,
    # Filter Objects to exclude
    [ValidateSet("VMwareVM","NutanixVM","HyperVVM","MSSQLDB","OracleDB","Fileset","VolumeGroup","ManagedVolume","SLADomain","PhysicalHost",
                 "NasShare","FilesetTemplate","AvailabilityGroup","DatabaseMount","Event", "EventSeries", "LDAPObject","LogShipping","ManagedVolumeExport",
                 "VMwareVMLiveMount","RubrikOrganization","Report","RubrikCluster","SQLInstance","vCenterServer","VMwareDatastore","VMwareHost",
                 "VMwareDatacenter", "VMwareCluster","APIToken","Archive","RubrikCluster", "RubrikClusterNetwork", "RubrikNode", "GuestOSCredential","ReplicationSource","ReplicationTarget",
                 "SCVMMServer","SyslogServer","RubrikUser","VCDvApp","VCDServer","HyperVHost","NTPServer","NotificationSetting","NutanixCluster","SMBDomain")]
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
        "VMwareVM"            = [pscustomobject]@{ associatedCmdlet = "Get-RubrikVM"; FriendlyName = "VMware VMs"; SupportsNameSearch = $true; NameSearchType = "WhereObject"; SupportsIDSearch = $true; NameField = "Name"; ObjectClass = @("VirtualMachines","AllProtectedObjects"); IDField = "id" }
        "NutanixVM"           = [pscustomobject]@{ associatedCmdlet = "Get-RubrikNutanixVM"; FriendlyName = "Nutanix VMs"; SupportsNameSearch = $true; NameSearchType = "WhereObject"; SupportsIDSearch = $true; NameField = "Name"; ObjectClass = @("VirtualMachines","AllProtectedObjects"); IDField = "id"  }
        "HyperVVM"            = [pscustomobject]@{ associatedCmdlet = "Get-RubrikHyperVVM"; FriendlyName = "HyperV VMs"; SupportsNameSearch = $true; NameSearchType = "WhereObject"; SupportsIDSearch = $true; NameField = "Name"; ObjectClass = @("VirtualMachines","AllProtectedObjects"); IDField = "id" }
        "MSSQLDB"             = [pscustomobject]@{ associatedCmdlet = "Get-RubrikDatabase"; FriendlyName = "MSSQL DBs"; SupportsNameSearch = $true; NameSearchType = "WhereObject"; SupportsIDSearch = $true; NameField = "Name"; ObjectClass = @("Databases","AllProtectedObjects"); IDField = "id" }
        "OracleDB"            = [pscustomobject]@{ associatedCmdlet = "Get-RubrikOracleDB"; FriendlyName = "Oracle DBs"; SupportsNameSearch = $true; NameSearchType = "WhereObject"; SupportsIDSearch = $true; NameField = "Name"; ObjectClass = @("Databases","AllProtectedObjects"); IDField = "id"  }
        "Fileset"             = [pscustomobject]@{ associatedCmdlet = "Get-RubrikFileset"; FriendlyName = "Filesets"; SupportsNameSearch = $true; NameSearchType = "NameFilter"; SupportsIDSearch = $true; NameField = "Name"; ObjectClass = @("FilesAndVolumes","AllProtectedObjects"); IDField = "id"  }
        "VolumeGroup"         = [pscustomobject]@{ associatedCmdlet = "Get-RubrikVolumeGroup"; FriendlyName = "Volume Groups"; SupportsNameSearch = $true; NameSearchType = "WhereObject"; SupportsIDSearch = $true; NameField = "Name"; ObjectClass = @("FilesAndVolumes","AllProtectedObjects"); IDField = "id" }
        "ManagedVolume"       = [pscustomobject]@{ associatedCmdlet = "Get-RubrikManagedVolume"; FriendlyName = "Managed Volumes"; SupportsNameSearch = $true; NameSearchType = "WhereObject"; SupportsIDSearch = $true; NameField = "Name"; ObjectClass = @("FilesAndVolumes","AllProtectedObjects"); IDField = "id" }
        "SLADomain"           = [pscustomobject]@{ associatedCmdlet = "Get-RubrikSLA"; FriendlyName = "SLA Domains"; SupportsNameSearch = $true; NameSearchType = "WhereObject"; SupportsIDSearch = $true; NameField = "Name"; ObjectClass = "InternalRubrikObjects"; IDField = "id" }
        "PhysicalHost"        = [pscustomobject]@{ associatedCmdlet = "Get-RubrikHost"; FriendlyName = "Physical Hosts"; SupportsNameSearch = $true; NameSearchType = "WhereObject"; SupportsIDSearch = $true; NameField = "Name"; ObjectClass = "FilesAndVolumes"; IDField = "id" }
        "NasShare"            = [pscustomobject]@{ associatedCmdlet = "Get-RubrikNasShare"; FriendlyName = "NAS Shares"; SupportsNameSearch = $true; NameSearchType = "WhereObject"; SupportsIDSearch = $true; NameField = "ExportPoint"; ObjectClass = @("FilesAndVolumes","AllProtectedObjects"); IDField = "id" }
        "FilesetTemplate"     = [pscustomobject]@{ associatedCmdlet = "Get-RubrikFilesetTemplate"; FriendlyName = "Fileset Templates"; SupportsNameSearch = $true; NameSearchType = "WhereObject"; SupportsIDSearch = $true; NameField = "Name"; ObjectClass = "FilesAndVolumes"; IDField = "id" }
        "AvailabilityGroup"   = [pscustomobject]@{ associatedCmdlet = "Get-RubrikAvailabilityGroup"; FriendlyName = "Availability Groups"; SupportsNameSearch = $true; NameSearchType = "WhereObject"; SupportsIDSearch = $true; NameField = "Name"; ObjectClass = "Databases"; IDField = "id" }
        "DatabaseMount"       = [pscustomobject]@{ associatedCmdlet = "Get-RubrikDatabaseMount"; FriendlyName = "Database Mounts"; SupportsNameSearch = $true; NameSearchType = "WhereObject"; SupportsIDSearch = $true; NameField = "mountedDatabaseName"; ObjectClass = "Databases"; IDField = "id" }
        "Event"               = [pscustomobject]@{ associatedCmdlet = "Get-RubrikEvent"; FriendlyName = "Events"; SupportsNameSearch = $true; NameSearchType = "WhereObject"; SupportsIDSearch = $true; NameField = "objectName"; ObjectClass = "InternalRubrikObjects"; IDField = "id" }
        "EventSeries"         = [pscustomobject]@{ associatedCmdlet = "Get-RubrikEventSeries"; FriendlyName = "Event Series"; SupportsNameSearch = $false; NameSearchType = "WhereObject"; SupportsIDSearch = $true; NameField = "ObjectName"; ObjectClass = "InternalRubrikObjects"; IDField = "eventSeriesId"}
        "LDAPObject"          = [pscustomobject]@{ associatedCmdlet = "Get-RubrikLDAP"; FriendlyName = "LDAP Objects"; SupportsNameSearch = $true; NameSearchType = "WhereObject"; SupportsIDSearch = $true; NameField = "Name"; ObjectClass = "InternalRubrikObjects"; IDField = "id" }
        "LogShipping"         = [pscustomobject]@{ associatedCmdlet = "Get-RubrikLogShipping"; FriendlyName = "Log Shipping Targets"; SupportsNameSearch = $true; NameSearchType = "WhereObject"; SupportsIDSearch = $true; NameField = "secondaryDatabaseName"; ObjectClass = "Databases"; IDField = "id" }
        "ManagedVolumeExport" = [pscustomobject]@{ associatedCmdlet = "Get-RubrikManagedVolumeExport"; FriendlyName = "Managed Volume Exports"; SupportsNameSearch = $true; NameSearchType = "WhereObject"; SupportsIDSearch = $true; NameField = "Name"; ObjectClass = "FilesAndVolumes"; IDField = "id" }
        "VMwareVMLiveMount"   = [pscustomobject]@{ associatedCmdlet = "Get-RubrikMount"; FriendlyName = "VMware VM Live Mount"; SupportsNameSearch = $false; SupportsIDSearch = $true; NameField = "Name"; ObjectClass = "VirtualMachines"; IDField = "id" }
        "RubrikOrganization"  = [pscustomobject]@{ associatedCmdlet = "Get-RubrikOrganization"; FriendlyName = "Rubrik Organizations"; SupportsNameSearch = $true; NameSearchType = "WhereObject"; SupportsIDSearch = $true; NameField = "Name"; ObjectClass = "InternalRubrikObjects"; IDField = "id" }
        "Report"              = [pscustomobject]@{ associatedCmdlet = "Get-RubrikReport"; FriendlyName = "Rubrik Reports"; SupportsNameSearch = $true; NameSearchType = "WhereObject"; SupportsIDSearch = $true; NameField = "Name"; ObjectClass = "InternalRubrikObjects"; IDField = "id" }
        "RubrikCluster"       = [pscustomobject]@{ associatedCmdlet = "Get-RubrikSetting"; FriendlyName = "Rubrik Clusters"; SupportsNameSearch = $true; NameSearchType = "WhereObject"; SupportsIDSearch = $true; NameField = "Name"; ObjectClass = "InternalRubrikObjects"; IDField = "id" }
        "RubrikNode"          = [pscustomobject]@{ associatedCmdlet = "Get-RubrikNode"; FriendlyName = "Rubrik Nodes"; SupportsNameSearch = $false; NameSearchType = "WhereObject"; SupportsIDSearch = $true; NameField = "Name"; ObjectClass = "InternalRubrikObjects"; IDField = "id" }
        "NotificationSetting" = [pscustomobject]@{ associatedCmdlet = "Get-RubrikNotificationSetting"; FriendlyName = "Rubrik Notification"; SupportsNameSearch = $false; NameSearchType = "WhereObject"; SupportsIDSearch = $true; NameField = "Name"; ObjectClass = "InternalRubrikObjects"; IDField = "id" }
        "NTPServer"           = [pscustomobject]@{ associatedCmdlet = "Get-RubrikNTPServer"; FriendlyName = "NTP Servers"; SupportsNameSearch = $true; NameSearchType = "WhereObject"; SupportsIDSearch = $false; NameField = "server"; ObjectClass = "InternalRubrikObjects"; IDField = "id" }
        "RubrikClusterNetwork"= [pscustomobject]@{ associatedCmdlet = "Get-RubrikClusterNetworkInterface"; FriendlyName = "Network Interfaces"; SupportsNameSearch = $true; NameSearchType = "WhereObject"; SupportsIDSearch = $false; NameField = "interfaceName"; ObjectClass = "InternalRubrikObjects"; IDField = "id" }
        "SQLInstance"         = [pscustomobject]@{ associatedCmdlet = "Get-RubrikSQLInstance"; FriendlyName = "SQL Instances"; SupportsNameSearch = $true; NameSearchType = "WhereObject"; SupportsIDSearch = $true; NameField = "Name"; ObjectClass = "Databases"; IDField = "id" }
        "vCenterServer"       = [pscustomobject]@{ associatedCmdlet = "Get-RubrikvCenter"; FriendlyName = "vCenter Servers"; SupportsNameSearch = $true; NameSearchType = "WhereObject"; SupportsIDSearch = $true; NameField = "Name"; ObjectClass = "InternalRubrikObjects"; IDField = "id" }
        "VMwareDatastore"     = [pscustomobject]@{ associatedCmdlet = "Get-RubrikVMwareDatastore"; FriendlyName = "VMware Datastores"; SupportsNameSearch = $true; NameSearchType = "WhereObject"; SupportsIDSearch = $true; NameField = "Name"; ObjectClass = "InternalRubrikObjects"; IDField = "id" }
        "VMwareDatacenter"    = [pscustomobject]@{ associatedCmdlet = "Get-RubrikVMwareDatacenter"; FriendlyName = "VMware Datacenters"; SupportsNameSearch = $true; NameSearchType = "WhereObject"; SupportsIDSearch = $true; NameField = "Name"; ObjectClass = "InternalRubrikObjects"; IDField = "id" }
        "VMwareCluster"       = [pscustomobject]@{ associatedCmdlet = "Get-RubrikVMwareCluster"; FriendlyName = "VMware Clusters"; SupportsNameSearch = $true; NameSearchType = "WhereObject"; SupportsIDSearch = $true; NameField = "Name"; ObjectClass = "InternalRubrikObjects"; IDField = "id" }
        "VMwareHost"          = [pscustomobject]@{ associatedCmdlet = "Get-RubrikVMwareHost"; FriendlyName = "VMware Hosts"; SupportsNameSearch = $true; NameSearchType = "WhereObject"; SupportsIDSearch = $true; NameField = "Name"; ObjectClass = "InternalRubrikObjects"; IDField = "id" }
        "HyperVHost"          = [pscustomobject]@{ associatedCmdlet = "Get-RubrikHypervHost"; FriendlyName = "HyperV Hosts"; SupportsNameSearch = $true; NameSearchType = "WhereObject"; SupportsIDSearch = $true; NameField = "Name"; ObjectClass = "InternalRubrikObjects"; IDField = "id" }
        "APIToken"            = [pscustomobject]@{ associatedCmdlet = "Get-RubrikAPIToken"; FriendlyName = "API Tokens"; SupportsNameSearch = $true; NameSearchType = "WhereObject"; SupportsIDSearch = $true; NameField = "Tag"; ObjectClass = "InternalRubrikObjects"; IDField = "id" }
        "Archive"             = [pscustomobject]@{ associatedCmdlet = "Get-RubrikArchive"; FriendlyName = "Archive Locations"; SupportsNameSearch = $true; NameSearchType = "WhereObject"; SupportsIDSearch = $true; NameField = "Name"; ObjectClass = "InternalRubrikObjects"; IDField = "id" }
        "GuestOSCredential"   = [pscustomobject]@{ associatedCmdlet = "Get-RubrikGuestOSCredential"; FriendlyName = "Guest Credentials"; SupportsNameSearch = $true; NameSearchType = "WhereObject"; SupportsIDSearch = $true; NameField = "Username"; ObjectClass = "InternalRubrikObjects"; IDField = "id" }
        "ReplicationSource"   = [pscustomobject]@{ associatedCmdlet = "Get-RubrikReplicationSource"; FriendlyName = "Replication Sources"; SupportsNameSearch = $true; NameSearchType = "WhereObject"; SupportsIDSearch = $true; NameField = "sourceClusterName"; ObjectClass = "InternalRubrikObjects"; IDField = "id" }
        "ReplicationTarget"   = [pscustomobject]@{ associatedCmdlet = "Get-RubrikReplicationTarget"; FriendlyName = "Replication Targets"; SupportsNameSearch = $true; NameSearchType = "WhereObject"; SupportsIDSearch = $true; NameField = "targetClusterName"; ObjectClass = "InternalRubrikObjects"; IDField = "id" }
        "SCVMMServer"         = [pscustomobject]@{ associatedCmdlet = "Get-RubrikSCVMM"; FriendlyName = "SCVMM Servers"; SupportsNameSearch = $true; NameSearchType = "WhereObject"; SupportsIDSearch = $true; NameField = "Name"; ObjectClass = "InternalRubrikObjects"; IDField = "id" }
        "SyslogServer"        = [pscustomobject]@{ associatedCmdlet = "Get-RubrikSyslogServer"; FriendlyName = "Syslog Servers"; SupportsNameSearch = $true; NameSearchType = "WhereObject"; SupportsIDSearch = $true; NameField = "hostname"; ObjectClass = "InternalRubrikObjects"; IDField = "id" }
        "RubrikUser"          = [pscustomobject]@{ associatedCmdlet = "Get-RubrikUser"; FriendlyName = "Rubrik Users"; SupportsNameSearch = $true; NameSearchType = "WhereObject"; SupportsIDSearch = $true; NameField = "username"; ObjectClass = "InternalRubrikObjects"; IDField = "id" }
        "VCDvApp"             = [pscustomobject]@{ associatedCmdlet = "Get-RubrikvApp"; FriendlyName = "VCD vApps"; SupportsNameSearch = $true; NameSearchType = "WhereObject"; SupportsIDSearch = $true; NameField = "Name"; ObjectClass = @("VirtualMachines","AllProtectedObjects"); IDField = "id" }
        "VCDServer"           = [pscustomobject]@{ associatedCmdlet = "Get-RubrikVCD"; FriendlyName = "VCD Servers"; SupportsNameSearch = $true; NameSearchType = "WhereObject"; SupportsIDSearch = $true; NameField = "hostname"; ObjectClass = "InternalRubrikObjects"; IDField = "id" }
        "NutanixCluster"      = [pscustomobject]@{ associatedCmdlet = "Get-RubrikNutanixCluster"; FriendlyName = "Nutanix Clusters"; SupportsNameSearch = $true; NameSearchType = "WhereObject"; SupportsIDSearch = $true; NameField = "Name"; ObjectClass = "InternalRubrikObjects"; IDField = "id" }
        "SMBDomain"          = [pscustomobject]@{ associatedCmdlet = "Get-RubrikSMBDomain"; FriendlyName = "SMB Domains"; SupportsNameSearch = $true; NameSearchType = "WhereObject"; SupportsIDSearch = $false; NameField = "Name"; ObjectClass = "InternalRubrikObjects"; IDField = "id" }
      }

    Write-Verbose -Message "Calculating which objects to parsed based on parameters specified"
    $ObjectsToParse = [System.Collections.ArrayList]@()
    # IF includes are passed, add them to arraylist
    If ($IncludeObjectClass -or $IncludeObjectType)
    {
      # Add all items included in Object Classes
      foreach ($ObjectClass in $IncludeObjectClass) {
        $ObjectTypes.GetEnumerator() | Where-Object {$_.Value.ObjectClass -contains "$ObjectClass"} | ForEach-Object {
          # If searching by name, ensure object type supports name search
          If ($NameFilter) {
            If ($_.Value.SupportsNameSearch) {
              [void]$ObjectsToParse.Add($_.Name)
              Write-Verbose -Message "Adding $($_.Name) due to membership of $($ObjectClass) Object Class"
            }
            else {
              Write-Verbose -Message "the $($_.Name) is a member of the $($ObjectClass) Object Class, however name search is not supported - skipping"
            }
          }
          # Else we are searching by ID - currently all objects support id search so just add.
          else {
            Write-Verbose -Message "Adding $($_.Name) due to membership of $($ObjectClass) Object Class"
            [void]$ObjectsToParse.Add($_.Name)
          }
        }
      }
      # Add all items passed implicitly
      foreach ($ObjectType in $IncludeObjectType) {
        # If searching by name, ensure object type supports name search
        If ($NameFilter) {
          If ($ObjectTypes["$ObjectType"].SupportsNameSearch) {
            [void]$ObjectsToParse.Add($ObjectType)
            Write-Verbose -Message "Adding $($ObjectType) - Explicitly specified"
          }
          else {
            Write-Verbose -Message "$($ObjectType) was explicitly specified however doesn't support name search - skipping"
          }
        }
        # Else we are searching by ID - currently all objects support id search so just add.
        else {
          [void]$ObjectsToParse.Add($ObjectType)
          Write-Verbose -Message "Adding $($ObjectType) - Explicitly specified"
        }
      }
    }
    else {
      # Else, no includes are passed - let's assume we want to process all object types
      $ObjectsToParse = [System.Collections.ArrayList]$ObjectTypes.Keys
      Write-Verbose -Message "No included parameters specified - adding all object types."
    }
    # If excludes are passed, remove them from arraylist
    if ($ExcludeObjectClass -or $ExcludeObjectType) {
      # Remove any items from Object Classes
      foreach ($ObjectClass in $ExcludeObjectClass) {
        $ObjectTypes.GetEnumerator() | Where-Object {$_.Value.ObjectClass -contains "$ObjectClass"} | ForEach-Object {
          [void]$ObjectsToParse.Remove($_.Name)
          Write-Verbose -Message "Removing $($_.Name) due to membership of $($ObjectClass)"
        }
      }
      # Remove and implicitly sent object types
      foreach ($ObjectType in $ExcludeObjectType) {
        $ObjectsToParse.Remove($ObjectType)
        Write-Verbose -Message "Removing $($ObjectType) - Explicitly specified"
      }
    }
    #Ensure objects only have one entry in arraylist
    $ObjectsToParse = $ObjectsToParse | Select-Object -Unique
    Write-Verbose -Message "Continuing to process $($ObjectsToParse)"
    # Initialize counters for progress bar
    $TotalObjectTypes = $ObjectsToParse.Count
    $Completed = 0

    # Loop through Object Types
    $result = ForEach ($ObjectType in $ObjectsToParse){
      $completed += 1
      Write-Progress -Activity "Searching Rubrik Objects - Operation $completed out of $TotalObjectTypes - $($ObjectTypes[$ObjectType].FriendlyName)"
      if ($NameFilter) {
        if ($ObjectTypes[$ObjectType].NameSearchType -eq 'NameFilter') {
          # Remove * from string
          $NameFilterMod = $NameFilter -replace '\*'
          $CmdletSplat = @{
            NameFilter = "$NameFilterMod"
            ErrorAction = "SilentlyContinue"
          }
          $WhereSplat = @{}
        }
        else {
          $CmdletSplat  = @{
            ErrorAction = "SilentlyContinue"
          }
          $WhereSplat = @{filterscript = [ScriptBlock]::Create('$_.'+"$($ObjectTypes[$ObjectType].NameField) -like '$NameFilter'")}
        }
      }
      if ($IDFilter) {
        $CmdletSplat = @{
          ErrorAction = "SilentlyContinue"
        }
        #$WhereSplat = @{filterscript = [ScriptBlock]::Create('$_.id -like '+"'$IdFilter'")}
        $WhereSplat = @{filterscript = [ScriptBlock]::Create('$_.'+"$($ObjectTypes[$ObjectType].IDField) -like '$IdFilter'")}
      }

      if ($CmdletSplat.NameFilter) {
        $ReturnedObjects = & $ObjectTypes[$ObjectType].associatedCmdlet @CmdletSplat
        # Only way I can figure out how to stop the total, data, links, hasmore from being returned when no results are found
        if ($ReturnedObjects.total -ne 0 -and $null -ne $ReturnedObjects) {
          $ReturnedObjects | Add-Member -NotePropertyName 'objectTypeMatch' -NotePropertyValue $ObjectType -PassThru
        }
      }
      if ($WhereSplat.FilterScript) {
          $ReturnedObjects = & $ObjectTypes[$ObjectType].associatedCmdlet @CmdletSplat | Where-Object @WhereSplat
          $ReturnedObjects | Add-Member -NotePropertyName 'objectTypeMatch' -NotePropertyValue $ObjectType -PassThru
        }

    }
    Write-Progress -Activity "Searching Rubrik Objects - Completed" -Completed

    return $Result

  } # End of process
} # End of function