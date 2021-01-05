#requires -Version 3
function Get-RubrikDatabase
{
  <#
      .SYNOPSIS
      Retrieves details on one or more databases known to a Rubrik cluster

      .DESCRIPTION
      The Get-RubrikDatabase cmdlet is used to pull a detailed data set from a Rubrik cluster on any number of databases.
      To narrow down the results, use the host and instance parameters to limit your search to a smaller group of objects.
      Alternatively, supply the Rubrik database ID to return only one specific database.

      .NOTES
      Written by Chris Wahl for community usage
      Twitter: @ChrisWahl
      GitHub: chriswahl

      .LINK
      https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/get-rubrikdatabase

      .EXAMPLE
      Get-RubrikDatabase -Name 'DB1' -SLA Gold
      This will return details on all databases named DB1 protected by the Gold SLA Domain on any known host or instance.

      .EXAMPLE
      Get-RubrikDatabase -Name 'DB1' -DetailedObject
      This will return the Database object with all properties, including additional details such as snapshots taken of the database and recovery point date/time information. Using this switch parameter negatively affects performance

      .EXAMPLE
      Get-RubrikDatabase -Name 'DB1' -Host 'Host1' -Instance 'MSSQLSERVER'
      This will return details on a database named "DB1" living on an instance named "MSSQLSERVER" on the host named "Host1".

      .EXAMPLE
      Get-RubrikDatabase -Relic
      This will return all removed databases that were formerly protected by Rubrik.

      .EXAMPLE
      Get-RubrikDatabase -Relic:$false
      This will return all databases that are currently protected by Rubrik.

      .EXAMPLE
      Get-RubrikDatabase
      This will return all databases that are currently or formerly protected by Rubrik.

      .EXAMPLE
      Get-RubrikDatabase -id 'MssqlDatabase:::aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee'
      This will return details on a single database matching the Rubrik ID of "MssqlDatabase:::aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee"
      Note that the database ID is globally unique and is often handy to know if tracking a specific database for longer workflows,
      whereas some values are not unique (such as nearly all hosts having one or more databases named "model") and more difficult to track by name.

      .EXAMPLE
      Get-RubrikDatabase -InstanceID MssqlInstance:::aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee
      This will return details on a single SQL instance matching the Rubrik ID of "MssqlInstance:::aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee"

      .EXAMPLE
      Get-RubrikDatabase -AvailabilityGroupName BestAvailabilityGroup

      This will return all databases in the BestAvailabilityGroup AG. If it matches multiple availability group names it will default to querying by host name instead

      .EXAMPLE
      Get-RubrikDatabase -AvailabilityGroupID 'MssqlAvailabilityGroup:::12345678-1234-abcd-8910-abbaabcdef90'

      Query for databases by availability group ID
  #>

  [CmdletBinding(DefaultParameterSetName = 'Query')]
  Param(
    # Rubrik's database id value
    [Parameter(
      ParameterSetName='ID',
      Position = 0,
      Mandatory = $true,
      ValueFromPipelineByPropertyName = $true)]
    [ValidateNotNullOrEmpty()]
    [String]$id,
    # Name of the database
    [Alias('Database')]
    [Parameter(
      ParameterSetName='Query',
      Position = 0)]
    [String]$Name,
    # Filter results to include only relic (removed) databases
    [Alias('is_relic')]
    [Switch]$Relic,
    # SLA Domain policy assigned to the database
    [String]$SLA,
    # Name of the database instance
    [String]$Instance,
    # Name of the database host
    [String]$Hostname,
    #ServerInstance name (combined hostname\instancename)
    [String]$ServerInstance,
    #SQL InstanceID, used as a unique identifier
    [Alias('instance_id')]
    [string]$InstanceID,
    # Availability Group Name
    [String]$AvailabilityGroupName,
    # SQL AvailabilityGroupID, used as a unique identifier
    [Alias('availability_group_id')]
    [string]$AvailabilityGroupID,
    # Filter the summary information based on the primarycluster_id of the primary Rubrik cluster. Use 'local' as the primary_cluster_id of the Rubrik cluster that is hosting the current REST API session.
    [Alias('primary_cluster_id')]
    [String]$PrimaryClusterID,
    # SLA id value
    [Alias('effective_sla_domain_id')]
    [String]$SLAID,
    # DetailedObject will retrieved the detailed database object, the default behavior of the API is to only retrieve a subset of the database object unless we query directly by ID. Using this parameter does affect performance as more data will be retrieved and more API-queries will be performed.
    [Switch]$DetailedObject,
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

    #region one-off
    if($ServerInstance){
      $SIobj = ConvertFrom-SqlServerInstance $ServerInstance
      $Hostname = $SIobj.hostname
      $Instance = $SIobj.instancename
    }

    if($Hostname.Length -gt 0 -and $Instance.Length -gt 0 -and $InstanceID.Length -eq 0){
      $InstanceID = (Get-RubrikSQLInstance -Hostname $Hostname -Name $Instance).id
    }

    if($PSBoundParameters.ContainsKey('AvailabilityGroupName')){
      $AvailabilityGroupID = (Get-RubrikAvailabilityGroup -GroupName $AvailabilityGroupName).id
      if ($AvailabilityGroupID.count -gt 1) {
        Write-Warning -Message 'Multiple availability group ids detected, querying by HostName instead'
        $HostName = $AvailabilityGroupName
      } elseif ([string]::IsNullOrEmpty($AvailabilityGroupID)) {
        Write-Warning -Message 'Availability Group Name does not match existing availability group, please verify the AG name.'
        $AvailabilityGroupID = 'MssqlAvailabilityGroup:::12345678-1234-abcd-8910-999999999999'
      }
      $PSBoundParameters.Add('AvailabilityGroupID',$AvailabilityGroupID)
    }
    #endregion
  }

  Process {

    #region One-off
    # If SLA paramter defined, resolve SLAID
    If ($SLA) {
      $TestSlaSplat = @{
        SLA = $SLA
        Inherit = $Inherit
        DoNotProtect = $DoNotProtect
      }
      if ($PrimaryClusterID) {
        $TestSlaSplat.PrimaryClusterID = $PrimaryClusterID
      }
      $SLAID = Test-RubrikSLA @TestSlaSplat
    }
    #endregion

    # If the switch parameter was not explicitly specified remove from query params
    if(-not $PSBoundParameters.ContainsKey('Relic')) {
      $Resources.Query.Remove('is_relic')
    }

    $uri = New-URIString -server $Server -endpoint ($resources.URI) -id $id
    $uri = Test-QueryParam -querykeys ($resources.Query.Keys) -parameters ((Get-Command $function).Parameters.Values) -uri $uri
    $body = New-BodyString -bodykeys ($resources.Body.Keys) -parameters ((Get-Command $function).Parameters.Values)
    $result = Submit-Request -uri $uri -header $Header -method $($resources.Method) -body $body
    $result = Test-ReturnFormat -api $api -result $result -location $resources.Result
    $result = Test-FilterObject -filter ($resources.Filter) -result $result
    $result = Set-ObjectTypeName -TypeName $resources.ObjectTName -result $result
    # If the Get-RubrikDatabase function has been called with the -DetailedObject parameter a separate API query will be performed if the initial query was not based on ID
    if (($DetailedObject) -and (-not $PSBoundParameters.containskey('id'))) {
      Write-Verbose -Message "DetailedObject detected, requerying for more detailed results"
      $result = Get-RubrikDetailedResult -result $result -cmdlet "$($MyInvocation.MyCommand.Name)"
    }
    return $result

  } # End of process
} # End of function