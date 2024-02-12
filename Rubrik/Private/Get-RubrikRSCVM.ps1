function Get-RubrikRSCVM {
  [CmdletBinding(DefaultParameterSetName = 'Query')]
  Param(
    # Name of the virtual machine
    [Parameter(
      ParameterSetName='Query',
      Position = 0,
      ValueFromPipelineByPropertyName = $true)]
    [ValidateNotNullOrEmpty()]
    [Alias('VM')]
    [String]$Name,
    # Virtual machine id
    [Parameter(
      ParameterSetName='ID',
      Position = 0,
      Mandatory = $true,
      ValueFromPipelineByPropertyName = $true)]
    [ValidateNotNullOrEmpty()]
    [String]$id,
    # Filter results to include only relic (removed) virtual machines
    [Parameter(ParameterSetName='Query')]
    [Alias('is_relic')]
    [Switch]$Relic,
    # DetailedObject will retrieved the detailed VM object, the default behavior of the API is to only retrieve a subset of the full VM object unless we query directly by ID. Using this parameter does affect performance as more data will be retrieved and more API-queries will be performed.
    [Parameter(ParameterSetName='Query')]
    [Switch]$DetailedObject,
    # SLA Domain policy assigned to the virtual machine
    [Parameter(ParameterSetName='Query')]
    [ValidateNotNullOrEmpty()]
    [String]$SLA,
    # Filter by SLA Domain assignment type
    [Parameter(ParameterSetName='Query')]
    [ValidateNotNullOrEmpty()]
    [ValidateSet('Derived', 'Direct','Unassigned')]
    [Alias('sla_assignment')]
    [String]$SLAAssignment,
    # Filter the summary information based on the primarycluster_id of the primary Rubrik cluster. Use 'local' as the primary_cluster_id of the Rubrik cluster that is hosting the current REST API session.
    [Parameter(ParameterSetName='Query')]
    [ValidateNotNullOrEmpty()]
    [Alias('primary_cluster_id')]
    [String]$PrimaryClusterID,
    # SLA id value
    [Parameter(ParameterSetName='Query')]
    [ValidateNotNullOrEmpty()]
    [Alias('effective_sla_domain_id')]
    [String]$SLAID,
    # Rubrik server IP or FQDN
    [Parameter(ParameterSetName='Query')]
    [Parameter(ParameterSetName='ID')]
    [String]$Server = $global:RubrikConnection.server,
    # API version
    [Parameter(ParameterSetName='Query')]
    [Parameter(ParameterSetName='ID')]
    [String]$api = $global:RubrikConnection.api
  )

  
  if ($Id) {

    $query = New-RscQuery -GqlQuery vSphereVmNew
    $query.var.filter = @()
    $query.Var.fid = $Id
    # Let's fetch some more objects other than the defaults now
    # configuredSlaDomain
    $sladomain = New-Object -TypeName RubrikSecurityCloud.Types.GlobalSlaReply
    $sladomain.id = "FETCH"
    $sladomain.name = "FETCH"
    $sladomain.isRetentionLockedSla = $true
    $query.field.configuredSlaDomain = $sladomain
    # Protection Date
    $query.field.ProtectionDate = New-Object -TypeName System.DateTime
    # Guest OS Name
    $query.field.GuestOsName = "FETCH"
    # Tools Installed
    $query.field.VMwareToolsInstalled = "FETCH"
    # Agent Status
    $query.field.AgentStatus = New-Object -TypeName RubrikSecurityCloud.Types.AgentStatus
    $query.field.AgentStatus.AgentStatusField = "CONNECTED"
    $query.field.AgentStatus.DisconnectReason = "FETCH"
    
    $response = Invoke-Rsc $query

    $response = $response | Select-Object -Property *, @{
      Name="ConfiguredSlaDomainName"; Expression={$_.configuredSlaDomain.Name}
    },@{
      Name="ConfiguedSlaDomainId"; Expression={$_.configuredSlaDomain.id}
    },@{
      Name="isConfiguredSlaDomainRetentionLocked"; Expression={$_.configuredSlaDomain.isRetentionLockedSla}
    },@{
      Name="EffectiveSlaDomainName"; Expression={$_.effectiveSlaDomain.Name}
    },@{
      Name="EffectiveSlaDomainId"; Expression={$_.effectiveSlaDomain.id}
    },@{
      Name="isEffectiveSlaDomainRetentionLocked"; Expression={$_.effectiveSlaDomain.isRetentionLockedSla}
    },@{
      Name="toolsInstalled"; Expression={$_.VMwareToolsInstalled}
    }

    return $response

  } else {
    if ($SLA) {
      $sla_id = (Get-RubrikSLA -Name "$SLA").id
      if ($null -ne $sla_id){
        $SLAID = $sla_id
      }
    }

    $filter = New-Object System.Collections.ArrayList
    $addFilter = $false

    if ($Name) {
      $filter.Add(
          @{
            "field" = "NAME_EXACT_MATCH"
            "texts" = "$Name"
          }
        ) | Out-Null
      $addFilter = $true
    }

    if ($PSBoundParameters.containsKey("Relic")) {
      if ($Relic -eq $true) {
        $filter.Add(
          @{
            "field" = "IS_RELIC"
            "texts" = "True"
          }
        ) | out-null
        $addFilter = $true
      } elseif ($Relic -eq $false) {
        $filter.Add(
          @{
            "field" = "IS_RELIC"
            "texts" = "False"
          }
        ) | out-null
        $addFilter = $true
      } 
    }

    if ($SLAID) {
      $filter.Add(
        @{
          "field" = "EFFECTIVE_SLA"
          "texts" = "$SLAID"
        }
      ) | Out-null
      $addFilter = $true
    }

    $query = New-RscQuery -GqlQuery vsphereVmNewConnection

    # Let's fetch some more objects other than the defaults now
    # configuredSlaDomain
    $sladomain = New-Object -TypeName RubrikSecurityCloud.Types.GlobalSlaReply
    $sladomain.id = "FETCH"
    $sladomain.name = "FETCH"
    $sladomain.isRetentionLockedSla = $true
    $query.field.nodes[0].configuredSlaDomain = $sladomain
    # Protection Date
    $query.field.nodes[0].ProtectionDate = New-Object -TypeName System.DateTime
    # Guest OS Name
    $query.field.nodes[0].GuestOsName = "FETCH"
    # Tools Installed
    $query.field.nodes[0].VMwareToolsInstalled = "FETCH"
    # Agent Status
    $query.field.nodes[0].AgentStatus = New-Object -TypeName RubrikSecurityCloud.Types.AgentStatus
    $query.field.nodes[0].AgentStatus.AgentStatusField = "CONNECTED"
    $query.field.nodes[0].AgentStatus.DisconnectReason = "FETCH"

    if ($addFilter -eq $true) {
      Write-Verbose -Message "Filter detecting, adding to variables"      
      $query.var.filter = $filter
    } 

    $response = (Invoke-Rsc $query).nodes

    # Let's do a little translation to try and match up as many fields from the GQL response to the REST response

    $response = $response | Select-Object -Property *, @{
      Name="ConfiguredSlaDomainName"; Expression={$_.configuredSlaDomain.Name}
    },@{
      Name="ConfiguedSlaDomainId"; Expression={$_.configuredSlaDomain.id}
    },@{
      Name="isConfiguredSlaDomainRetentionLocked"; Expression={$_.configuredSlaDomain.isRetentionLockedSla}
    },@{
      Name="EffectiveSlaDomainName"; Expression={$_.effectiveSlaDomain.Name}
    },@{
      Name="EffectiveSlaDomainId"; Expression={$_.effectiveSlaDomain.id}
    },@{
      Name="isEffectiveSlaDomainRetentionLocked"; Expression={$_.effectiveSlaDomain.isRetentionLockedSla}
    },@{
      Name="toolsInstalled"; Expression={$_.VMwareToolsInstalled}
    }


    return $response
  }
}