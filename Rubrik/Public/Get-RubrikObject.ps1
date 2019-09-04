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
    [String]$Name,
    #Filter by ID
    [Parameter(Mandatory=$true,ParameterSetName='FilterByID')]
    [ValidateNotNullOrEmpty()]    
    [String]$id, 
    # Filter Objects to include
    [ValidateSet("VMwareVM","NutanixVM","HyperVVM","MSSSQLDB","OracleDB","Fileset","VolumeGroup","ManagedVolume","SLADomain","PhysicalHost",
                 "NasShare","FilesetTemplate","AvailabilityGroup","DatabaseMount","Event","LDAPObject","LogShipping")]
    [String[]]$ObjectsToInclude, 
    # Filter Objects to exclude
    [ValidateSet("VMwareVM","NutanixVM","HyperVVM","MSSSQLDB","OracleDB","Fileset","VolumeGroup","ManagedVolume","SLADomain","PhysicalHost",
                 "NasShare","FilesetTemplate","AvailabilityGroup","DatabaseMount","Event","LDAPObject","LogShipping")]
    [String[]]$ObjectsToExclude,     
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

    # Hashtable containing information around each object type. Name must match ValidateSet in ObjectsToInclude parameter
    $ObjectTypes =
    @{
        "VMwareVM"          = [pscustomobject]@{ associatedCmdlet = "Get-RubrikVM"; FriendlyName = "VMware VMs"; SupportsNameSearch = $true; SupportsIDSearch = $true }
        "NutanixVM"         = [pscustomobject]@{ associatedCmdlet = "Get-RubrikNutanixVM"; FriendlyName = "Nutanix VMs"; SupportsNameSearch = $true; SupportsIDSearch = $true }
        "HyperVVM"          = [pscustomobject]@{ associatedCmdlet = "Get-RubrikHyperVVM"; FriendlyName = "HyperV VMs"; SupportsNameSearch = $true; SupportsIDSearch = $true }
        "MSSQLDB"           = [pscustomobject]@{ associatedCmdlet = "Get-RubrikDatabase"; FriendlyName = "MSSQL DBs"; SupportsNameSearch = $true; SupportsIDSearch = $true }
        "OracleDB"          = [pscustomobject]@{ associatedCmdlet = "Get-RubrikOracleDB"; FriendlyName = "Oracle DBs"; SupportsNameSearch = $true; SupportsIDSearch = $true }
        "Fileset"           = [pscustomobject]@{ associatedCmdlet = "Get-RubrikFileset"; FriendlyName = "Filesets"; SupportsNameSearch = $true; SupportsIDSearch = $true }
        "VolumeGroup"       = [pscustomobject]@{ associatedCmdlet = "Get-RubrikVolumeGroup"; FriendlyName = "Volume Groups"; SupportsNameSearch = $true; SupportsIDSearch = $true }
        "ManagedVolume"     = [pscustomobject]@{ associatedCmdlet = "Get-RubrikManagedVolume"; FriendlyName = "Managed Volumes"; SupportsNameSearch = $true; SupportsIDSearch = $true }
        "SLADomain"         = [pscustomobject]@{ associatedCmdlet = "Get-RubrikSLA"; FriendlyName = "SLA Domains"; SupportsNameSearch = $true; SupportsIDSearch = $true }
        "PhysicalHost"      = [pscustomobject]@{ associatedCmdlet = "Get-RubrikHost"; FriendlyName = "Physical Hosts"; SupportsNameSearch = $true; SupportsIDSearch = $true }
        "NasShare"          = [pscustomobject]@{ associatedCmdlet = "Get-RubrikNasShare"; FriendlyName = "NAS Shares"; SupportsNameSearch = $false; SupportsIDSearch = $true }
        "FilesetTemplate"   = [pscustomobject]@{ associatedCmdlet = "Get-RubrikFilesetTemplate"; FriendlyName = "Fileset Templates"; SupportsNameSearch = $true; SupportsIDSearch = $true }
        "AvailabilityGroup" = [pscustomobject]@{ associatedCmdlet = "Get-RubrikAvailabilityGroup"; FriendlyName = "Availability Groups"; SupportsNameSearch = $true; SupportsIDSearch = $true }
        "DatabaseMount"     = [pscustomobject]@{ associatedCmdlet = "Get-RubrikDatabaseMount"; FriendlyName = "Database Mounts"; SupportsNameSearch = $false; SupportsIDSearch = $true }
        "Event"             = [pscustomobject]@{ associatedCmdlet = "Get-RubrikEvent"; FriendlyName = "Events"; SupportsNameSearch = $false; SupportsIDSearch = $true }
        "LDAPObject"        = [pscustomobject]@{ associatedCmdlet = "Get-RubrikLDAP"; FriendlyName = "LDAP Objects"; SupportsNameSearch = $true; SupportsIDSearch = $true }
        "LogShipping"       = [pscustomobject]@{ associatedCmdlet = "Get-RubrikLogShipping"; FriendlyName = "Log Shipping Targets"; SupportsNameSearch = $false; SupportsIDSearch = $true }
    }

    # Create new variable to use in order to determine which objects to parse.
    # Since $ObjectsToInclude has a ValidateSet, we cannot simply copy Object Type keys to it.
    # If no objects were passed as a parameter, include all objects
    If ($ObjectsToInclude) { $ObjectsToParse = [System.Collections.ArrayList]$ObjectsToInclude }
    else { 
      $ObjectsToParse = [System.Collections.ArrayList]$ObjectTypes.Keys
      If ($ObjectsToExclude) {
        foreach ($ObjectType in $ObjectsToExclude) {
          $ObjectsToParse.Remove($ObjectType)
        }
      } 
    }

    # Build parameter queries for individual cmdlets
    $IndividualCmdletParams = ""
    # Add PrimaryClusterID if passed
    If ($PrimaryClusterID) { $IndividualCmdletParams += " -PrimaryClusterID '$PrimaryClusterId'" }
    # Add Name filter if passed
    if ($Name) { 
      $IndividualCmdletParams +=' | where-object { $_.Name -like ' + "'$Name' }" 
      # retrieve and remove objects not supporting name search
      $ObjectTypes.GetEnumerator() | Where-Object {$_.Value.SupportsIDSearch -eq $false} | ForEach-Object {$ObjectsToParse.Remove($_.Name)}
    }
    if ($id) { 
      $IndividualCmdletParams += ' | where-object { $_.id -like ' + "'$id' }" 
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
      $comm = $ObjectTypes[$ObjectType].associatedCmdlet + $IndividualCmdletParams + " | Select-Object -Property *, @{label='objectType';expression={'"+$ObjectType+"'}}"
      $Result += Invoke-Expression -Command $comm
    }
    Write-Progress -Activity "Searching Rubrik Objects - Completed" -Completed

    return $Result

  } # End of process
} # End of function