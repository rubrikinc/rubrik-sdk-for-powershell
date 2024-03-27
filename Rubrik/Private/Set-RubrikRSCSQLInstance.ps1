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
[int]$LogBackupFrequencyInSeconds,
# Number of hours backups will be retained in Rubrik
# NOTE: Default of -1 is used to get around ints defaulting as 0
[int]$LogRetentionHours,
# Boolean declaration for copy only backups on the instance.
[switch]$CopyOnly,
# SLA Domain ID for the database
[Alias('ConfiguredSlaDomainId')]
[Parameter(ParameterSetName = 'SLA_Explicit')]
[string]$SLAID,
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

    $RscParams = @{}

    # Retrieve RSC MSSQL Instance Object
    $RscMssqlInstance = Get-RscMssqlInstance -id $id
    $RscParams.Add("RscMssqlInstance",$RscMssqlInstance)
    
    
    # Retrieve SLA Object
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
    

    if ($LogBackupFrequencyInSeconds) {
        $RscParams.Add("logBackupFrequencyInSeconds", $LogBackupFrequencyInSeconds)
    }
    if ($LogRetentionHours) {
        $RscParams.Add("logRetentionHours", $LogRetentionHours)
    }

    if ($DoNotProtect) {
        $RscParams.Add("DoNotProtect",$true)
        $RscParams.Add("ExistingSnapshotRetention","RETAIN_SNAPSHOTS")
    }

    if ($Inherit) {
        $RscParams.Add("ClearExistingProtection", $true)
    }

    $response = Set-RscMssqlInstance @RscParams
    return $response
}