function Protect-RubrikRSCDatabase
{
 
  [CmdletBinding(SupportsShouldProcess = $true,ConfirmImpact = 'High')]
  Param(
    # Database ID
    [Parameter(Mandatory = $true,ValueFromPipelineByPropertyName = $true)]
    [ValidateNotNullOrEmpty()] 
    [String]$id,
    # The SLA Domain in Rubrik
    [Parameter(ParameterSetName = 'SLA_Explicit')]
    [String]$SLA,
    # Removes the SLA Domain assignment
    [Parameter(ParameterSetName = 'SLA_Unprotected')]
    [Switch]$DoNotProtect,
    # Inherits the SLA Domain assignment from a parent object
    [Parameter(ParameterSetName = 'SLA_Inherit')]
    [Switch]$Inherit,
    # SLA id value
    [Alias('configuredSlaDomainId')]
    [String]$SLAID,
    # Determine the retention settings for the already existing snapshots
    [Parameter(ParameterSetName = 'SLA_Unprotected')]
    [ValidateSet('RetainSnapshots', 'KeepForever', 'ExpireImmediately')]
    [string] $ExistingSnapshotRetention = 'RetainSnapshots',
    # Rubrik server IP or FQDN
    [String]$Server = $global:RubrikConnection.server,
    # API version
    [String]$api = $global:RubrikConnection.api
  )



  $RscParams = @{}

  # Retrieve RSC MSSQL Database Object

  # For now, let's get the name and use internal calls, but once the parameter is added we should be able to use the next line
  #$database = Get-RscMssqlDatabase -id $id
  $dbname = (Get-RubrikDatabase -id $id).name
  $database = Get-RscMssqlDatabase -name "$dbname" | Where-Object {$_.id -eq "$id"}
  $RscParams.Add("RscMssqlDatabase",$database)
  
  # need cluster object
  $query = New-RSCQueryCluster -Operation Cluster
  $query.Var.clusterUuid = "$($global:rubrikConnection.clusterId)"
  $localcluster = Invoke-RSC $query
  $RscParams.Add("RscCluster",$localcluster)

  # Now SLA
  $slaobject = $null
  if ($SLA) {
      $slaobject = Get-RscSla | where-object {$_.name -eq "$SLA"}
  }
  if ($SLAID) {
      $slaobject = Get-RscSla | where-object {$_.id -eq "$slaid"}
  }
  if ($slaobject) {
      $RscParams.Add("RscSlaDomain",$slaobject)
  }

  if ($DoNotProtect) {
      $RscParams.Add("DoNotProtect",$true)
      if ($ExistingSnapshotRetention -eq "RetainSnapshots") {
        $RscParams.Add("ExistingSnapshotRetention","RETAIN_SNAPSHOTS")
      } elseif ($ExistingSnapshotRetention -eq "KeepForever") {
        $RscParams.Add("ExistingSnapshotRetention","KEEP_FOREVER")
      } elseif ($ExistingSnapshotRetention -eq "ExpireImmediately") {
        $RscParams.Add("ExistingSnapshotRetention","EXPIRE_IMMEDIATELY")
      }
  }
  if ($Inherit) {
    $RscParams.Add("ClearExistingProtection",$true)
  }

  Write-Verbose -Message "Calling Set-RscMssqlDatabase"
  $response = Set-RscMssqlDatabase @RscParams
  return $response

}