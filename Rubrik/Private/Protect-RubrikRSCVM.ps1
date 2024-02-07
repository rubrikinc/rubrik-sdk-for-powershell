function Protect-RubrikRSCVM
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

$query = @'
  mutation assignSLA($input: AssignSlaInput!) {
      m: assignSla (input:$input) {
        success
      }
  }
'@

  if ($SLAID) {
    $body = @{
        "query" = $query
        "variables" = @{
            "input" = @{
                "slaDomainAssignType" = "protectWithSlaId"
                "objectIds" = @("$id")
                "slaOptionalId" = "$SLAID"
            }
        }
    } | ConvertTo-Json -Compress -Depth 5
  } elseif ($DoNotProtect) {
    $body = @{
        "query" = $query
        "variables" = @{
            "input" = @{
                "slaDomainAssignType" = "doNotProtect"
                "objectIds" = @("$id")
            }
        }
    } | ConvertTo-Json -Compress -Depth 5
  } elseif ($Inherit) {
    $body = @{
        "query" = $query
        "variables" = @{
            "input" = @{
                "slaDomainAssignType" = "noAssignment"
                "objectIds" = @("$id")
            }
        }
    } | ConvertTo-Json -Compress -Depth 5
  }

$response = Invoke-RubrikGQLRequest -query $body | ConvertFrom-Json 
return $response.data.m
} # End of function