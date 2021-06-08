#requires -Version 3
function Set-RubrikHvmFormatAutoUpgrade
{
  <#
      .SYNOPSIS
      Updates the Hyper-V Virtual Machine format auto upgrade settings on a Rubrik cluster

      .DESCRIPTION
      The Set-RubrikHvmFormatAutoUpgrade cmdlet is used to update the Hyper-V Virtual Machine format auto upgrade settings to a Rubrik cluster.
      There are two configurations available:
        - 'migrateFastVirtualDiskBuild', or 'AutoUpgradeMode', is a boolean
          flag that controls the use of the fast VHDX builder during
          Hyper-V Virtual Machine migration. When the value of the flag
          is true, the Hyper-V Virtual Machine uses the fast VHDX builder the next time the
          Hyper-V Virtual Machine is backed up. A value of false disables the fast VHDX builder.
          This flag is used in combination with the maxFullMigrationStoragePercentage
          value.
        - 'maxFullMigrationStoragePercentage', is an integer which specifies a
          percentage of the total storage space. When performing a full Hyper-V Virtual Machine
          backup operation would bring the total used storage space above this
          threshold, the cluster takes incremental backups instead. This value is
          used in combination with the migrateFastVirtualDiskBuild flag.

      .NOTES
      Written by Abhinav Prakash for community usage
      github: ab-prakash

      .LINK
      https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/set-rubrikhvmformatautoupgrade

      .EXAMPLE
      Set-RubrikHvmFormatAutoUpgrade -migrateFastVirtualDiskBuild $True
      This will set the cluster configuration to automatically upgrade format for all Hyper-V Virtual Machines.

      .EXAMPLE
      Set-RubrikHvmFormatAutoUpgrade -migrateFastVirtualDiskBuild $False
      This will set the cluster configuration to not automatically upgrade format for any Hyper-V Virtual Machines.

      .EXAMPLE
      Set-RubrikHvmFormatAutoUpgrade -maxFullMigrationStoragePercentage 70
      This will set the cluster configuration to allow automatic upgrade only when the projected cluster space usage after upgrade does not exceed 70% of total cluster storage.

      .EXAMPLE
      Set-RubrikHvmFormatAutoUpgrade -migrateFastVirtualDiskBuild $True -maxFullMigrationStoragePercentage 70
      This will set both configurations on the cluster.
  #>

  [CmdletBinding()]
  Param(
    # Mode of automatic upgrade
    [Alias('AutoUpgradeMode')]
    [Boolean]$migrateFastVirtualDiskBuild,
    # Maximum allowed cluster storage space usage if upgrade happens
    [Int]$maxFullMigrationStoragePercentage,
    # Filter the report based on whether the Hyper-V Virtual Machine used fast VHDX format for its latest snapshot.
    [String]$Server = $global:RubrikConnection.server,
    # API version
    [String]$api = $global:RubrikConnection.api
  )

  Begin {

    # The Begin section is used to perform one-time loads of data necessary to carry out the function's purpose
    # If a command needs to be run with each iteration or pipeline input, place it in the Process section

    # Check to ensure that a session to the Rubrik cluster exists and load the needed header data for authentication
    Test-RubrikConnection

    # API data references the name of the function
    # For convenience, that name is saved here to $function
    $function = $MyInvocation.MyCommand.Name

    # Retrieve all of the URI, method, body, query, result, filter, and success details for the API endpoint
    Write-Verbose -Message "Gather API Data for $function"
    $resources = Get-RubrikAPIData -endpoint $function
    Write-Verbose -Message "Load API data for $($resources.Function)"
    Write-Verbose -Message "Description: $($resources.Description)"
  }

  Process {

    $isFlagSet = $PSBoundParameters.ContainsKey('migrateFastVirtualDiskBuild') 
    $isPercentageSet = $PSBoundParameters.ContainsKey('maxFullMigrationStoragePercentage') 

    if (-not ($isFlagSet -or $isPercentageSet)) {
      Write-Host "Invalid input: At least one of the parameters, 'migrateFastVirtualDiskBuild' and 'maxFullMigrationStoragePercentage', should be non-empty. Exiting the process."
      return $null
    }
    
    # Precheck for valid inputs of maxFullMigrationStoragePercentage
    if ($isPercentageSet -and ($maxFullMigrationStoragePercentage -lt 0) -or ($maxFullMigrationStoragePercentage -gt 100)) {
      Write-Host "Invalid input value for maxFullMigrationStoragePercentage. Please use an integer between 0 and 100."
      return $null
    }

    Write-Verbose "Setting cluster-wide Hyper-V Virtual Machine configuration:"
    if ($isFlagSet) {
      Write-Verbose "'migrateFastVirtualDiskBuild' to $migrateFastVirtualDiskBuild"
    }
    if ($isPercentageSet) {
      Write-Verbose "'maxFullMigrationStoragePercentage' to $maxFullMigrationStoragePercentage"
    }

    $uri = New-URIString -server $Server -endpoint ($resources.URI) -id $id
    $uri = Test-QueryParam -querykeys ($resources.Query.Keys) -parameters ((Get-Command $function).Parameters.Values) -uri $uri
    $body = New-BodyString -bodykeys ($resources.Body.Keys) -parameters ((Get-Command $function).Parameters.Values)
    $result = Submit-Request -uri $uri -header $Header -method $($resources.Method) -body $body
    $result = Test-ReturnFormat -api $api -result $result -location $resources.Result
    $result = Test-FilterObject -filter ($resources.Filter) -result $result

    if (($isFlagSet -and ($result.migrateFastVirtualDiskBuild -ne $migrateFastVirtualDiskBuild)) -or
      ($isPercentageSet -and ($result.maxFullMigrationStoragePercentage -ne $maxFullMigrationStoragePercentage))) {
      Write-Warning "The operation failed to set the configs. Use -Verbose to see more information."
    }
    else {
      Write-Host ""
      if ($isFlagSet) {
        if ($migrateFastVirtualDiskBuild -eq $false) {
          Write-Host "Successfully disabled Hyper-V Format Auto-Upgrade."
        }
        if ($migrateFastVirtualDiskBuild -eq $true) {
          Write-Host "Successfully configured to Auto-Upgrade Hyper-V Virtual Machines on Next Backup."
        }
      }
      if ($isPercentageSet) {
        Write-Host "Successfully set the cluster space consumption limit to $maxFullMigrationStoragePercentage%."
      }
    }
    return $result
  } # End of process
} # End of function