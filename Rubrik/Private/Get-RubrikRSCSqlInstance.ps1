function Get-RubrikRSCSQLInstance {
    [CmdletBinding(DefaultParameterSetName = 'Query')]
    Param(
         # Name of the instance
         [Parameter(
          ParameterSetName='Query',
          Position = 0)]
         [Alias('InstanceName')]
         [String]$Name,
         # SLA Domain policy assigned to the database
         [String]$SLA,
         # Name of the database host
         [String]$Hostname,
         #ServerInstance name (combined hostname\instancename)
         [String]$ServerInstance,
         # Filter the summary information based on the primarycluster_id of the primary Rubrik cluster. Use: local as the primary_cluster_id of the Rubrik cluster that is hosting the current REST API session.
         [Alias('primary_cluster_id')]
         [String]$PrimaryClusterID,
         # Rubrik's database id value
         [Parameter(
          ParameterSetName='ID',
          Position = 0,
          Mandatory = $true,
          ValueFromPipelineByPropertyName = $true)]
         [String]$id,
         # SLA id value
         [String]$SLAID,
         # Rubrik server IP or FQDN
         [String]$Server = $global:RubrikConnection.server,
         # API version
         [ValidateNotNullorEmpty()]
         [String]$api = $global:RubrikConnection.api
    )
    
    $RscParams = @{}

    # need cluster object
    $query = New-RSCQueryCluster -Operation Cluster
    $query.Var.clusterUuid = "$($global:rubrikConnection.clusterId)"
    $localcluster = Invoke-RSC $query
    $RscParams.Add("RscCluster",$localcluster)
    
    if ($id) {
        $RscParams.Add("Id",$id)
    }
    if ($ServerInstance) {
        # Break this apart and set individual params
        $Name = $ServerInstance.Split("\")[1]
        $HostName = $ServerInstance.Split("\")[0]
    }

    if ($Name) { 
        $RscParams.Add("InstanceName",$Name)
    }

    if ($Hostname) {
        #$HostObject = Get-RubrikHost -Name "$Hostname"
        $RscParams.Add("HostName",$Hostname)
    }



    $response = Get-RscMssqlInstance @RscParams

    # If SLA/SLAID were passed we need to filter returned results
    if ($SLA) {
        $SLAID = (Get-RubrikSLA -Name $SLA).id
    }
    if ($SLAID) {
        $response = $response | Where-Object {$_.EffectiveSlaDomain.Id -eq "$SLAID"}
    }
    return $response

}