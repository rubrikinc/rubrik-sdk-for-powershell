#Requires -Version 3
function Protect-RubrikFileset
{
  <#
    .SYNOPSIS
    Connects to Rubrik and assigns an SLA to a fileset

    .DESCRIPTION
    The Protect-RubrikFileset cmdlet will update a fileset's SLA Domain assignment within the Rubrik cluster.
    The SLA Domain contains all policy-driven values needed to protect data.
    Note that this function requires the fileset ID value, not the name of the fileset, since fileset names are not unique across clusters.
    It is suggested that you first use Get-RubrikFileset to narrow down the one or more filesets to protect, and then pipe the results to Protect-RubrikFileset.
    You will be asked to confirm each fileset you wish to protect, or you can use -Confirm:$False to skip confirmation checks.

    .NOTES
    Written by Chris Wahl for community usage
    Twitter: @ChrisWahl
    GitHub: chriswahl

    .LINK
    https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/protect-rubrikfileset

    .EXAMPLE
    Get-RubrikFileset 'C_Drive' | Protect-RubrikFileset -SLA 'Gold'

    This will assign the Gold SLA Domain to any fileset named "C_Drive"

    .EXAMPLE
    Get-RubrikFileset 'C_Drive' -HostName 'Server1' | Protect-RubrikFileset -SLA 'Gold' -Confirm:$False

    This will assign the Gold SLA Domain to the fileset named "C_Drive" residing on the host named "Server1" without asking for confirmation

    .EXAMPLE
    Get-RubrikFileset 'C_Drive' -HostName 'Server1' | Protect-RubrikFileset -SLA 'Gold' -SLAPrimaryClusterId 57bbd327-477d-40d8-b1d8-5820b37d88e5
    
    This will assign the Gold SLA Domain to the fileset named "C_Drive" residing on the host named "Server1" on the cluster id specified in SLAPrimaryClusterId

    .EXAMPLE
    Get-RubrikFileset 'C_Drive' -HostName 'Server1' | Protect-RubrikFileset -DoNotProtect -ExistingSnapshotRetention ExpireImmediately

    This will set the C_Drive fileset to not protected and subsequently expire existing snapshots
  #>

  [CmdletBinding(SupportsShouldProcess = $true,ConfirmImpact = 'High')]
  Param(
    # Fileset ID
    [Parameter(Mandatory = $true,ValueFromPipelineByPropertyName = $true)]
    [String]$id,
    # The SLA Domain in Rubrik
    [Parameter(
      ParameterSetName = 'SLA_Name',
      Mandatory = $true
    )]
    [String]$SLA,
    # The PrimaryClusterId of SLA Domain on Rubrik, defaults to local
    [Parameter(ParameterSetName = 'SLA_Name')]
    [String]$SLAPrimaryClusterId = 'local',
    # Removes the SLA Domain assignment
    [Parameter(
      ParameterSetName = 'SLA_Unprotected',
      Mandatory = $true
    )]
    [Switch]$DoNotProtect,
    # SLA id value
    [Parameter(
      ParameterSetName = 'SLA_ByID',
      Mandatory = $true
    )]
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

  Begin {

    # The Begin section is used to perform one-time loads of data necessary to carry out the function's purpose
    # If a command needs to be run with each iteration or pipeline input, place it in the Process section

    # Check to ensure that a session to the Rubrik cluster exists and load the needed header data for authentication
    Test-RubrikConnection

    # API data references the name of the function
    # For convenience, that name is saved here to $function
    $function = $MyInvocation.MyCommand.Name

    # Retrieve all of the URI, method, body, query, result, filter, and success details for the API endpoint
    Write-Verbose -Message "Gather API Data for $function"
    $resources = Get-RubrikAPIData -endpoint $function
    Write-Verbose -Message "Load API data for $($resources.Function)"
    Write-Verbose -Message "Description: $($resources.Description)"

  }

  Process {

    #region One-off
    If ($SLA -or $DoNotProtect) {
      $TestSlaSplat = @{
        SLA = $SLA
        DoNotProtect = $DoNotProtect
      }
      if ($SLAPrimaryClusterId) {
        $TestSlaSplat.PrimaryClusterID = $SLAPrimaryClusterId
      }
      $SLAID = Test-RubrikSLA @TestSlaSplat
    }
    #endregion One-off

    if (($rubrikConnection.version.substring(0,5) -as [version]) -ge [version]5.2) {
      $uri = New-URIString -server $Server -endpoint ($resources.URI) -id $slaid
      
      $HashProps = [ordered]@{
        managedIds = @($id)
      }
      if ($ExistingSnapshotRetention) {
        $HashProps.existingSnapshotRetention = $ExistingSnapshotRetention
      }

      $body = [pscustomobject]$HashProps | ConvertTo-Json
      Write-Verbose -Message "Body = $body"
    } else {
      $uri = New-URIString -server $Server -endpoint ($resources.URI) -id $id
      $uri = Test-QueryParam -querykeys ($resources.Query.Keys) -parameters ((Get-Command $function).Parameters.Values) -uri $uri
      $body = New-BodyString -bodykeys ($resources.Body.Keys) -parameters ((Get-Command $function).Parameters.Values)  
    }


    $result = Submit-Request -uri $uri -header $Header -method $($resources.Method) -body $body
    $result = Test-ReturnFormat -api $api -result $result -location $resources.Result
    $result = Test-FilterObject -filter ($resources.Filter) -result $result

    return $result

  } # End of process
} # End of function