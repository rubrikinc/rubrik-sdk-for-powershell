function Get-RubrikRSCFilesetTemplate
{
  [CmdletBinding()]
  Param(
    # Retrieve fileset templates with a name matching the provided name. The search is performed as a case-insensitive infix search.
    [Parameter(Position = 0)]
    [Alias('FilesetTemplate')]
    [String]$Name,
    # Filter the summary information based on the operating system type of the fileset. Accepted values: 'Windows', 'Linux'
    [ValidateSet('Windows', 'Linux')]
    [Alias('operating_system_type')]
    [String]$OperatingSystemType,
    # Filter the summary information based on the share type of the fileset. Accepted values: 'NFS', 'SMB'
    [ValidateSet('NFS', 'SMB')]
    [Alias('share_type')]
    [String]$shareType,
    # Filter the summary information based on the primarycluster_id of the primary Rubrik cluster. Use 'local' as the primary_cluster_id of the Rubrik cluster that is hosting the current REST API session.
    [Alias('primary_cluster_id')]
    [String]$PrimaryClusterID,
    # The ID of the fileset template
    [Parameter(ValueFromPipelineByPropertyName = $true)]
    [String]$id,
    # Rubrik server IP or FQDN
    [String]$Server = $global:RubrikConnection.server,
    # API version
    [ValidateNotNullorEmpty()]
    [String]$api = $global:RubrikConnection.api
  )




  if ($Id) {
    $query = New-RSCQuery -GqlQuery filesetTemplate
    $query.Var.fid = "$Id"
    $query.Field.includes = "FETCH"
    $response = Invoke-RSC $query
  }
  else {
    $query = New-RscQuery -GqlQuery filesetTemplates -AddField Nodes.Includes
    Write-Verbose -Message "Filtering list by cluster"
    $filter = New-Object System.Collections.ArrayList

    $filter.Add(
      @{
        "field" = "CLUSTER_ID"
        "texts" = "$($global:rubrikConnection.clusterId)"
      }
    ) | Out-Null

    if ($Name) {
        $filter.Add( 
          @{
            "field" = "NAME_EXACT_MATCH"
            "texts" = "$Name"
          }
        ) | Out-Null
    }

    if ($OperatingSystemType) {
        if ($OperatingSystemType -eq "Windows") {
            $hostRoots = @("WINDOWS_HOST_ROOT")
        } elseif ($OperatingSystemType -eq "Linux") {
            $hostRoots = @("LINUX_HOST_ROOT")
        } else {
            $hostRoots = @("WINDOWS_HOST_ROOT", "LINUX_HOST_ROOT") 
        }
    } else {
        $hostRoots = @("WINDOWS_HOST_ROOT", "LINUX_HOST_ROOT")
    }

    Write-Verbose -Message "Adding filter to query"      
    $query.var.filter = $filter

    $response = foreach ($hostRoot in $hostRoots) {
        $query.Var.hostRoot = "$hostRoot"
        $response = Invoke-RSC $query
        $response.nodes
    }
  }


  return $response
}