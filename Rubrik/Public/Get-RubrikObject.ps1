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
    # Filter the summary information based on the primarycluster_id of the primary Rubrik cluster. Use 'local' as the primary_cluster_id of the Rubrik cluster that is hosting the current REST API session.
    [String]$PrimaryClusterID,   
    # Filter results to return VMware VMs  
    [Switch]$IncludeVMwareVMs,
    # Filter results to return Nutanix VMs
    [Switch]$IncludeNutanixVMs,
    # Filter results to return Hyper-V VMs
    [Switch]$IncludeHyperVVMs,
    # Filter results to return MSSQL Databases
    [Switch]$IncludeMSSQLDBs,
    # Filter results to return Oracle Databases
    [Switch]$IncludeOracleDBs,
    # Filter results to return Filesets
    [Switch]$IncludeFilesets,
    # Filter results to return Volume Groups
    [Switch]$IncludeVolumeGroups,
    # Filter results to return ManagedVolumes
    [Switch]$IncludeManagedVolumes,
    # Filter results to return SLA Domains
    [Switch]$IncludeSLADomains,
    # Filter results to return Physical Hosts
    [Switch]$IncludePhysicalHosts,
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

    # Build parameter queries for individual cmdlets
    $IndividualCmdletParams = ""
    If ($PrimaryClusterID) { $IndividualCmdletParams += " -PrimaryClusterID '$PrimaryClusterId'" }
    if ($Name) { $IndividualCmdletParams +=' | where-object { $_.Name -like ' + "'$Name' }" }
    if ($id) { $IndividualCmdletParams += ' | where-object { $_.id -like ' + "'$id' }" }

    # Hashtable containing information around each object type.
    $ObjectTypes =
    @{
        "VMwareVMs"       = [pscustomobject]@{ ParameterName = 'IncludeVMwareVMs'; ObjectTypeLabel = "VMwareVM"; associatedCmdlet = "Get-RubrikVM $IndividualCmdletParams"; parameterPassed = $IncludeVMwareVMs}
        "NutanixVMs"      = [pscustomobject]@{ ParameterName = 'IncludeNutanixVMs'; ObjectTypeLabel = "NutanixVM"; associatedCmdlet = "Get-RubrikNutanixVM $IndividualCmdletParams"; parameterPassed = $IncludeNutanixVMs}
        "HyperVVMs"       = [pscustomobject]@{ ParameterName = 'IncludeHyperVVMs'; ObjectTypeLabel = "HyperVVM"; associatedCmdlet = "Get-RubrikHyperVVM $IndividualCmdletParams"; parameterPassed = $IncludeHyperVVMs}
        "MSSQLDBs"        = [pscustomobject]@{ ParameterName = 'IncludeMSSSQLDBs'; ObjectTypeLabel = "MSSQLDB"; associatedCmdlet = "Get-RubrikDatabase $IndividualCmdletParams"; parameterPassed = $IncludeMSSQLDBs}
        "OracleDBs"       = [pscustomobject]@{ ParameterName = 'IncludeOracleDBs'; ObjectTypeLabel = "OracleDB"; associatedCmdlet = "Get-RubrikOracleDB $IndividualCmdletParams"; parameterPassed = $IncludeOracleDBs}
        "Filesets"        = [pscustomobject]@{ ParameterName = 'IncludeFilesets'; ObjectTypeLabel = "Fileset"; associatedCmdlet = "Get-RubrikFileset $IndividualCmdletParams"; parameterPassed = $IncludeFilesets}
        "VolumeGroups"    = [pscustomobject]@{ ParameterName = 'IncludeVolumeGroups'; ObjectTypeLabel = "VolumeGroup"; associatedCmdlet = "Get-RubrikVolumeGroup $IndividualCmdletParams"; parameterPassed = $IncludeVolumeGroups}
        "ManagedVolumes"  = [pscustomobject]@{ ParameterName = 'IncludeManagedVolumes'; ObjectTypeLabel = "ManagedVolume"; associatedCmdlet = "Get-RubrikManagedVolume $IndividualCmdletParams"; parameterPassed = $IncludeManagedVolumes}
        "SLADomains"      = [pscustomobject]@{ ParameterName = 'IncludeSLADomains'; ObjectTypeLabel = "SLADomain"; associatedCmdlet = "Get-RubrikSLA $IndividualCmdletParams"; parameterPassed = $IncludeSLADomains}
        "PhysicalHosts"   = [pscustomobject]@{ ParameterName = 'IncludePhysicalHosts'; ObjectTypeLabel = "PhysicalHost"; associatedCmdlet = "Get-RubrikHost $IndividualCmdletParams"; parameterPassed = $IncludePhysicalHosts}
    }

    # Iterate through all objects unless filter object parameters have been implicity specified.
    $ProcessAllObjectTypes = $true
    
    # Determine if and the number of object types needed to parse from parameters passed
    $TotalObjectTypes = 0
    ForEach ($key in $ObjectTypes.Keys) {
      # If individual object type filter has been passed, override processing all object types
      if ($ObjectTypes[$key].parameterPassed)  {
        $ProcessAllObjectTypes = $false
        $TotalObjectTypes += 1
      }
    }
   
    # If no individual object types were passed in parameters set progress bar counter to count of all object types.
    if ($ProcessAllObjectTypes) { $TotalObjectTypes = $ObjectTypes.Count}

    # Initialize Result
    $Result = @()
    
    # Completed counter for progress message
    $Completed = 0
    # Parse individual or all object types
    ForEach ($key in $ObjectTypes.Keys) {
      if ($ObjectTypes[$key].parameterPassed -or $ProcessAllObjectTypes) {
        $completed += 1
        Write-Progress -Activity "Searching Rubrik Objects - Operation $completed out of $TotalObjectTypes - $($ObjectTypes[$key].ObjectTypeLabel)"
        # Build out cmdlet syntax and execute
        $comm = $ObjectTypes[$key].associatedCmdlet + " | Select-Object -Property *, @{label='objectType';expression={'"+$ObjectTypes[$key].ObjectTypeLabel+"'}}"
        $Result += Invoke-Expression -Command $comm
      }
    }
    Write-Progress -Activity "Searching Rubrik Objects - Completed" -Completed

    return $Result

  } # End of process
} # End of function