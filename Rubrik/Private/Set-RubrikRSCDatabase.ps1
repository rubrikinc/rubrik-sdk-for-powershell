function Set-RubrikRSCDatabase {
    [CmdletBinding(SupportsShouldProcess = $true,ConfirmImpact = 'High',DefaultParameterSetName="Global")]
    Param(
      # Rubrik's database id value
      [Parameter(ValueFromPipelineByPropertyName = $true)]
      [ValidateNotNullOrEmpty()] 
      [Parameter(ParameterSetName='Global',Mandatory=$true)]
      [parameter(ParameterSetName='SLAbyId',Mandatory=$true)]
      [parameter(ParameterSetName='SLAbyName',Mandatory=$true)]
      [Parameter(ParameterSetName='PreScript',Mandatory=$true)]
      [Parameter(ParameterSetName='PreScriptDisable',Mandatory=$true)]
      [Parameter(ParameterSetName='PostScriptDisable',Mandatory=$true)]
      [Parameter(ParameterSetName='PostScript',Mandatory=$true)]
      [String]$id,
      
      #SLA Domain ID for the database
      [parameter(ParameterSetName='SLAbyId',Mandatory=$true)]
      [Parameter(ParameterSetName='PreScript')]
      [Parameter(ParameterSetName='PreScriptDisable')]
      [Parameter(ParameterSetName='PostScriptDisable')]
      [Parameter(ParameterSetName='PostScript')]
      [Parameter(ParameterSetName='Global')]
      [Alias('ConfiguredSlaDomainId')]
      [string]$SLAID,
      # The SLA Domain name in Rubrik
      [parameter(ParameterSetName='SLAbyName',Mandatory=$true)]
      [Parameter(ParameterSetName='PreScript')]
      [Parameter(ParameterSetName='PreScriptDisable')]
      [Parameter(ParameterSetName='PostScriptDisable')]
      [Parameter(ParameterSetName='PostScript')]
      [Parameter(ParameterSetName='Global')]
      [String]$SLA,
      
      #Pre-backup script parameters
      [Parameter(ParameterSetName='PreScript',Mandatory=$true)]
      [string]$PreScriptPath,
      [Parameter(ParameterSetName='PreScript',Mandatory=$true)]
      [ValidateSet('abort','continue')]
      [string]$PreScriptErrorAction,
      [Parameter(ParameterSetName='PreScript',Mandatory=$true)]
      [int]$PreTimeoutMs,
      
      [Parameter(ParameterSetName='PreScriptDisable',Mandatory=$true)]
      [Parameter(ParameterSetName='Global')]
      [parameter(ParameterSetName='SLAbyId')]
      [parameter(ParameterSetName='SLAbyName')]
      [parameter(ParameterSetName='PostScriptDisable')]
      [parameter(ParameterSetName='PostScript')]
      [switch]$DisablePreBackupScript,
      
      #Post-backup script parameters
      [Parameter(ParameterSetName='PostScript',Mandatory=$true)]
      [string]$PostScriptPath,
      [Parameter(ParameterSetName='PostScript',Mandatory=$true)]
      [ValidateSet('abort','continue')]
      [string]$PostScriptErrorAction,
      [Parameter(ParameterSetName='PostScript',Mandatory=$true)]
      [int]$PostTimeoutMs,
      
      [Parameter(ParameterSetName='PostScriptDisable',Mandatory=$true)]
      [Parameter(ParameterSetName='Global')]
      [parameter(ParameterSetName='SLAbyId')]
      [parameter(ParameterSetName='SLAbyName')]
      [parameter(ParameterSetName='PreScript')]
      [Parameter(ParameterSetName='PreScriptDisable')]
      [switch]$DisablePostBackupScript,
      
      #Number of seconds between log backups if db is in FULL or BULK_LOGGED
      #NOTE: Default of -1 is used to get around ints defaulting as 0
      [int]$LogBackupFrequencyInSeconds = -1,
      #Number of hours backups will be retained in Rubrik
      #NOTE: Default of -1 is used to get around ints defaulting as 0
      [int]$LogRetentionHours = -1,
      #Boolean declaration for copy only backups on the database.
      [Switch]$CopyOnly,
      #Number of max data streams Rubrik will use to back up the database
      #NOTE: Default of -1 is used to get around ints defaulting as 0
      [int]$MaxDataStreams = -1,
      # Rubrik server IP or FQDN
      [String]$Server = $global:RubrikConnection.server,
      # API version
      [ValidateNotNullorEmpty()]
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
    
    # need cluster object
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

    if ($CopyOnly -and $CopyOnly -eq $true) {
        $RscParams.Add("CopyOnly",$true)
    } elseif ($CopyOnly -and $CopyOnly -eq $false) {
        $RscParams.Add("CopyOnly",$false)
    }
    
    # Pre Script Params
    if ($PreScriptPath) {
        $RscParams.Add("PreBackupScriptPath", $PreScriptPath)
    }
    if ($PreScriptErrorAction) {
        if ($PreScriptErrorAction -eq "abort") {
            $RscParams.Add("PreBackupScriptErrorAction", "SCRIPT_ERROR_ACTION_ABORT")
        } elseif ($PreScriptErrorAction -eq "continue") {
            $RscParams.Add("PreBackupScriptErrorAction", "SCRIPT_ERROR_ACTION_CONTINUE")
        }
    }
    if ($PreTimeoutMs) {
        $RscParams.Add("PreBackupScriptTimeoutMs",$PreTimeoutMs)
    }
    if ($DisablePreBackupScript) {
        $RscParams.Add("RemovePreBackupScript", $true)
    }

    # Post Script Parameters
    if ($PostScriptPath) {
        $RscParams.Add("PostBackupScriptPath", $PostScriptPath)
    }
    if ($PostScriptErrorAction) {
        if ($PostScriptErrorAction -eq "abort") {
            $RscParams.Add("PostBackupScriptErrorAction", "SCRIPT_ERROR_ACTION_ABORT")
        } elseif ($PostScriptErrorAction -eq "continue") {
            $RscParams.Add("PostBackupScriptErrorAction", "SCRIPT_ERROR_ACTION_CONTINUE")
        }
    }
    if ($PostTimeoutMs) {
        $RscParams.Add("PostBackupScriptTimeoutMs",$PreTimeoutMs)
    }
    if ($DisablePostBackupScript) {
        $RscParams.Add("RemovePostBackupScript", $true)
    }

    if ($LogBackupFrequencyInSeconds) {
        $RscParams.Add("logBackupFrequencyInSeconds", $LogBackupFrequencyInSeconds)
    }
    if ($LogRetentionHours) {
        $RscParams.Add("logRetentionHours", $LogRetentionHours)
    }
    if ($MaxDataStreams) {
        $RscParams.Add("MaxDataStreams",$MaxDataStreams)
    }

    Set-RscMssqlDatabase @RscParams


}