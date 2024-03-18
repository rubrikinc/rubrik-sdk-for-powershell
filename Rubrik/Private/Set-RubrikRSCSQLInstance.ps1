function Set-RubrikRSCSQLInstance {
    [CmdletBinding( SupportsShouldProcess = $true,
    ConfirmImpact = 'High',
    DefaultParameterSetName = 'NoSLA_Changes'
)]
Param(
# Rubrik's database id value
[Parameter(
Position = 0,
Mandatory = $true,
ValueFromPipelineByPropertyName = $true)]
[Parameter(ParameterSetName = 'SLA_Explicit')]
[Parameter(ParameterSetName = 'SLA_Unprotected')]
[Parameter(ParameterSetName = 'SLA_Inherit')]
[Parameter(ParameterSetName = 'NoSLA_Changes')]
[ValidateNotNullOrEmpty()] 
[string]$id,
# Number of seconds between log backups if db s are in FULL or BULK_LOGGED
# NOTE: Default of -1 is used to get around ints defaulting as 0
[int]$LogBackupFrequencyInSeconds = -1,
# Number of hours backups will be retained in Rubrik
# NOTE: Default of -1 is used to get around ints defaulting as 0
[int]$LogRetentionHours = -1,
# Boolean declaration for copy only backups on the instance.
[switch]$CopyOnly,
# SLA Domain ID for the database
[Alias('ConfiguredSlaDomainId')]
[Parameter(ParameterSetName = 'SLA_Explicit')]
[string]$SLAID = (Test-RubrikSLA -SLA $SLA -Inherit $Inherit -DoNotProtect $DoNotProtect -Mandatory:$false),
# The SLA Domain name in Rubrik
[Parameter(ParameterSetName = 'SLA_Explicit')]
[string]$SLA,
# Removes the SLA Domain assignment
[Parameter(ParameterSetName = 'SLA_Unprotected')]
[switch]$DoNotProtect,
# Inherits the SLA Domain assignment from a parent object
[Parameter(ParameterSetName = 'SLA_Inherit')]
[switch]$Inherit,
# Rubrik server IP or FQDN
[string]$Server = $global:RubrikConnection.server,
# API version
[ValidateNotNullorEmpty()]
[string]$api = $global:RubrikConnection.api
)


    #Write-Host $PSCmdlet.ParameterSetName
    
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

    
    


    Write-Host @RscParams



    Set-RscMssqlDatabase @RscParams


}