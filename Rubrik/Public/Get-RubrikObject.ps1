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
      Get-RubrikObject
      This will return all known objects within the Rubrik cluster

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

    # Hashtable containing information around each object type. Name must match ValidateSet in IncludeObjectType parameter
    $ObjectTypes =
    @{
        "VMwareVM"            = [pscustomobject]@{ associatedCmdlet = "Get-RubrikVM"; FriendlyName = "VMware VMs"; SupportsNameSearch = $true; SupportsIDSearch = $true; NameField = "Name" }
        "NutanixVM"           = [pscustomobject]@{ associatedCmdlet = "Get-RubrikNutanixVM"; FriendlyName = "Nutanix VMs"; SupportsNameSearch = $true; SupportsIDSearch = $true; NameField = "Name"  }
        "HyperVVM"            = [pscustomobject]@{ associatedCmdlet = "Get-RubrikHyperVVM"; FriendlyName = "HyperV VMs"; SupportsNameSearch = $true; SupportsIDSearch = $true; NameField = "Name" }
        "MSSQLDB"             = [pscustomobject]@{ associatedCmdlet = "Get-RubrikDatabase"; FriendlyName = "MSSQL DBs"; SupportsNameSearch = $true; SupportsIDSearch = $true; NameField = "Name" }
        "OracleDB"            = [pscustomobject]@{ associatedCmdlet = "Get-RubrikOracleDB"; FriendlyName = "Oracle DBs"; SupportsNameSearch = $true; SupportsIDSearch = $true; NameField = "Name" }
        "Fileset"             = [pscustomobject]@{ associatedCmdlet = "Get-RubrikFileset"; FriendlyName = "Filesets"; SupportsNameSearch = $true; SupportsIDSearch = $true; NameField = "Name" }
        "VolumeGroup"         = [pscustomobject]@{ associatedCmdlet = "Get-RubrikVolumeGroup"; FriendlyName = "Volume Groups"; SupportsNameSearch = $true; SupportsIDSearch = $true; NameField = "Name" }
        "ManagedVolume"       = [pscustomobject]@{ associatedCmdlet = "Get-RubrikManagedVolume"; FriendlyName = "Managed Volumes"; SupportsNameSearch = $true; SupportsIDSearch = $true; NameField = "Name" }
        "SLADomain"           = [pscustomobject]@{ associatedCmdlet = "Get-RubrikSLA"; FriendlyName = "SLA Domains"; SupportsNameSearch = $true; SupportsIDSearch = $true; NameField = "Name" }
        "PhysicalHost"        = [pscustomobject]@{ associatedCmdlet = "Get-RubrikHost"; FriendlyName = "Physical Hosts"; SupportsNameSearch = $true; SupportsIDSearch = $true; NameField = "Name" }
        "NasShare"            = [pscustomobject]@{ associatedCmdlet = "Get-RubrikNasShare"; FriendlyName = "NAS Shares"; SupportsNameSearch = $true; SupportsIDSearch = $true; NameField = "ExportPoint" }
        "FilesetTemplate"     = [pscustomobject]@{ associatedCmdlet = "Get-RubrikFilesetTemplate"; FriendlyName = "Fileset Templates"; SupportsNameSearch = $true; SupportsIDSearch = $true; NameField = "Name" }
        "AvailabilityGroup"   = [pscustomobject]@{ associatedCmdlet = "Get-RubrikAvailabilityGroup"; FriendlyName = "Availability Groups"; SupportsNameSearch = $true; SupportsIDSearch = $true; NameField = "Name" }
        "DatabaseMount"       = [pscustomobject]@{ associatedCmdlet = "Get-RubrikDatabaseMount"; FriendlyName = "Database Mounts"; SupportsNameSearch = $true; SupportsIDSearch = $true; NameField = "mountedDatabaseName" }
        "Event"               = [pscustomobject]@{ associatedCmdlet = "Get-RubrikEvent"; FriendlyName = "Events"; SupportsNameSearch = $true; SupportsIDSearch = $true; NameField = "objectName" }
        "LDAPObject"          = [pscustomobject]@{ associatedCmdlet = "Get-RubrikLDAP"; FriendlyName = "LDAP Objects"; SupportsNameSearch = $true; SupportsIDSearch = $true; NameField = "Name" }
        "LogShipping"         = [pscustomobject]@{ associatedCmdlet = "Get-RubrikLogShipping"; FriendlyName = "Log Shipping Targets"; SupportsNameSearch = $true; SupportsIDSearch = $true; NameField = "secondaryDatabaseName" }
        "ManagedVolumeExport" = [pscustomobject]@{ associatedCmdlet = "Get-RubrikManagedVolumeExport"; FriendlyName = "Managed Volume Exports"; SupportsNameSearch = $false; SupportsIDSearch = $true; NameField = "Name" }
        "VMwareVMLiveMount"   = [pscustomobject]@{ associatedCmdlet = "Get-RubrikMount"; FriendlyName = "VMware VM Live Mount"; SupportsNameSearch = $false; SupportsIDSearch = $true; NameField = "Name" }
        "RubrikOrganization"  = [pscustomobject]@{ associatedCmdlet = "Get-RubrikOrganization"; FriendlyName = "Rubrik Organizations"; SupportsNameSearch = $true; SupportsIDSearch = $true; NameField = "Name" }
        "Report"              = [pscustomobject]@{ associatedCmdlet = "Get-RubrikReport"; FriendlyName = "Rubrik Reports"; SupportsNameSearch = $true; SupportsIDSearch = $true; NameField = "Name" }
        "RubrikCluster"       = [pscustomobject]@{ associatedCmdlet = "Get-RubrikSetting"; FriendlyName = "Rubrik Clusters"; SupportsNameSearch = $true; SupportsIDSearch = $true; NameField = "Name" }
        "SQLInstance"         = [pscustomobject]@{ associatedCmdlet = "Get-RubrikSQLInstance"; FriendlyName = "SQL Instances"; SupportsNameSearch = $true; SupportsIDSearch = $true; NameField = "Name" }
        "vCenterServer"       = [pscustomobject]@{ associatedCmdlet = "Get-RubrikvCenter"; FriendlyName = "vCenter Servers"; SupportsNameSearch = $true; SupportsIDSearch = $true; NameField = "Name" }
        "VMwareDatastore"     = [pscustomobject]@{ associatedCmdlet = "Get-RubrikVMwareDatastore"; FriendlyName = "VMware Datastores"; SupportsNameSearch = $true; SupportsIDSearch = $true; NameField = "Name" }
        "VMwareHost"          = [pscustomobject]@{ associatedCmdlet = "Get-RubrikVMwareHost"; FriendlyName = "VMware Hosts"; SupportsNameSearch = $true; SupportsIDSearch = $true; NameField = "Name" }
        "APIToken"            = [pscustomobject]@{ associatedCmdlet = "Get-RubrikAPIToken"; FriendlyName = "API Tokens"; SupportsNameSearch = $true; SupportsIDSearch = $true; NameField = "Tag" }
    }

    # Create new variable to use in order to determine which objects to parse.
    # Since $IncludeObjectType has a ValidateSet, we cannot simply copy Object Type keys to it.
    # If no objects were passed as a parameter, include all objects
    If ($IncludeObjectType) { $ObjectsToParse = [System.Collections.ArrayList]$IncludeObjectType }
    else { 
      $ObjectsToParse = [System.Collections.ArrayList]$ObjectTypes.Keys
      If ($ExcludeObjectType) {
        foreach ($ObjectType in $ExcludeObjectType) {
          $ObjectsToParse.Remove($ObjectType)
        }
      } 
    }

    # Build parameter queries for individual cmdlets
    $IndividualCmdletParams = ""
    # Add Name filter if passed
    if ($NameFilter) { 
      $IndividualCmdletParams +=' | where-object { $_.Name -like ' + "'$NameFilter' }" 
      # retrieve and remove objects not supporting name search
      $ObjectTypes.GetEnumerator() | Where-Object {$_.Value.SupportsNameSearch -eq $false} | ForEach-Object {$ObjectsToParse.Remove($_.Name)}
    }
    if ($IdFilter) { 
      $IndividualCmdletParams += ' | where-object { $_.id -like ' + "'$IdFilter' }" 
      # retrieve and remove objects not supporting ID search
      $ObjectTypes.GetEnumerator() | Where-Object {$_.Value.SupportsIdSearch -eq $false} | ForEach-Object {$ObjectsToParse.Remove($_.Name)}
    }

    # initialize counters for progress bar
    $TotalObjectTypes = $ObjectsToParse.Count
    $Completed = 0

    # Initialize Result
    $Result = @()

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