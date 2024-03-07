function Protect-RubrikRSCHyperVVM
{


  [CmdletBinding(SupportsShouldProcess = $true,ConfirmImpact = 'High',DefaultParameterSetName="None")]
  Param(
    # Virtual machine ID
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
    [String]$SLAID ,
    # Determine the retention settings for the already existing snapshots
    [Parameter(ParameterSetName = 'SLA_Unprotected')]
    [ValidateSet('RetainSnapshots', 'KeepForever', 'ExpireImmediately')]
    [string] $ExistingSnapshotRetention = 'RetainSnapshots',
    # Rubrik server IP or FQDN
    [String]$Server = $global:RubrikConnection.server,
    # API version
    [String]$api = $global:RubrikConnection.api
  )

  if ($SLA) {
    $SLAID = (Get-RubrikRSCSLA -Name "$SLA").id
  }

  if ($SLAID) {
    $input = @{
        "slaDomainAssignType" = "protectWithSlaId"
        "objectIds" = @("$id")
        "slaOptionalId" = "$SLAID"
    }
  } elseif ($DoNotProtect) {
    $input = @{
        "slaDomainAssignType" = "doNotProtect"
        "objectIds" = @("$id")
    }
  } elseif ($Inherit) {
    $input = @{
        "slaDomainAssignType" = "noAssignment"
        "objectIds" = @("$id")
    }
  }

  $mutation = New-RscMutation -gqlMutation assignSla
  $mutation.var.input = $input
  $response = Invoke-Rsc $mutation
  return $response
  
} # End of function