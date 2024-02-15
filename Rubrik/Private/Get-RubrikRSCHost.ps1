function Get-RubrikRSCHost
{
  [CmdletBinding(DefaultParameterSetName = 'Query')]
  Param(
    # Retrieve hosts with a host name matching the provided name. The search type is infix
    [Parameter(
      ParameterSetName='Query',
      Position = 0)]
    [Alias('Hostname')]
    [String]$Name,
    # Filter the summary information based on the operating system type. Accepted values are 'Windows', 'Linux', 'ANY', 'NONE'. Use NONE to only return information for hosts templates that do not have operating system type set. Use ANY to only return information for hosts that have operating system type set.
    [ValidateSet('Windows','Linux','Any','None')]
    [Alias('operating_system_type')]
    [String]$Type,
    # Filter the summary information based on the primarycluster_id of the primary Rubrik cluster. Use 'local' as the primary_cluster_id of the Rubrik cluster that is hosting the current REST API session.
    [Alias('primary_cluster_id')]
    [String]$PrimaryClusterID,
    # ID of the registered host
    [Parameter(
      ParameterSetName='ID',
      Position = 0,
      Mandatory = $true,
      ValueFromPipelineByPropertyName = $true)]
    [ValidateNotNullOrEmpty()]
    [String]$id,
    # DetailedObject will retrieved the detailed VM object, the default behavior of the API is to only retrieve a subset of the full VM object unless we query directly by ID. Using this parameter does affect performance as more data will be retrieved and more API-queries will be performed.
    [Parameter(ParameterSetName='Query')]
    [Switch]$DetailedObject,
    # Rubrik server IP or FQDN
    [String]$Server = $global:RubrikConnection.server,
    # API version
    [String]$api = $global:RubrikConnection.api
  )

  if ($Id) {
    $query = New-RscQuery -GqlQuery physicalHost
    $query.Var.fid = "$Id"

    
    <#
    # Populate Additional fields to fetch
    # For Example 
    $query.field.nodes[1].ProtectedObjectCount = 0
    #>
    
    $response = Invoke-RSC $query
  } else {
    $query = New-RscQuery -GqlQuery physicalHosts

    <#
    # Populate Additional fields to fetch
    # For Example 
    $query.field.nodes[1].ProtectedObjectCount = 0
    #>
    

    if ($Name) { 
        $query.Var.filter = @{
            field = "NAME_EXACT_MATCH"
            texts = "$Name"
        }
    }

    if ($Type) {
        if ($Type -eq "Windows") {
            $hostRoots = @("WINDOWS_HOST_ROOT")
        } elseif ($Type -eq "Linux") {
            $hostRoots = @("LINUX_HOST_ROOT")
        } else {
            $hostRoots = @("WINDOWS_HOST_ROOT", "LINUX_HOST_ROOT") 
        }
    } else {
        $hostRoots = @("WINDOWS_HOST_ROOT", "LINUX_HOST_ROOT")
    }

    $response = foreach ($hostRoot in $hostRoots) {
        $query.Var.hostRoot = "$hostRoot"
        $response = Invoke-RSC $query
        $response.nodes
    }

    
  }


    <#
    # Rename properties to match old SDK
    # For Example 
    $response = $response | Select-Object -Property *, @{
        Name="isRetentionLocked"; Expression={$_.isRetentionLockedSla}
    },@{
        Name="numProtectedObjects"; Expression={$_.ProtectedObjectCount}
    }
    #>
    
  return $response
  

}