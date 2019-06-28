#requires -Version 3
function Get-RubrikOracleDB
{
  <#  
    .SYNOPSIS
    Retrieves details on one or more Oracle DBs known to a Rubrik cluster

    .DESCRIPTION
    The Get-RubrikOracleDB cmdlet is used to pull a detailed data set from a Rubrik cluster on any number of Oracle DBs
    
    .NOTES
    Written by Jaap Brasser for community usage
    Twitter: @jaap_brasser
    GitHub: jaapbrasser
    
    .LINK
    http://rubrikinc.github.io/rubrik-sdk-for-powershell/reference/Get-RubrikOracleDB.html
    
    .EXAMPLE
    Get-RubrikOracleDB -Name 'OracleDB1'
    This will return details on all Oracle DBs named "OracleDB1".
    
    .EXAMPLE
    Get-RubrikOracleDB -Name 'OracleDB1' -SLA Gold
    This will return details on all Oracle DBs named "OracleDB1" that are protected by the Gold SLA Domain.
    
    .EXAMPLE
    Get-RubrikOracleDB -Relic
    This will return all removed Oracle DBs that were formerly protected by Rubrik.
    
    .EXAMPLE
    Get-RubrikOracleDB -Name OracleDB1 -DetailedObject
    This will return the Oracle DB object with all properties, including additional details such as snapshots taken of the Oracle DB. Using this switch parameter negatively affects performance as more API queries will be performed.
  #>

  [CmdletBinding()]
  Param(
    # Name of the Oracle DB
    [Parameter(Position = 0,ValueFromPipelineByPropertyName = $true)]
    [String]$Name,
    # Filter results to include only relic (removed) Oracle DBs
    [Alias('is_relic')]    
    [Switch]$Relic,
    [Alias('is_live_mount')]    
    [Switch]$LiveMount,
    # DetailedObject will retrieved the detailed VM object, the default behavior of the API is to only retrieve a subset of the full VM object unless we query directly by ID. Using this parameter does affect performance as more data will be retrieved and more API-queries will be performed.
    [Switch]$DetailedObject,
    # SLA Domain policy assigned to the Oracle DB
    [String]$SLA, 
    # Filter by SLA Domain assignment type
    [Alias('sla_assignment')]
    [ValidateSet('Derived', 'Direct','Unassigned')]
    [String]$SLAAssignment,     
    # Filter the summary information based on the primarycluster_id of the primary Rubrik cluster. Use **_local** as the primary_cluster_id of the Rubrik cluster that is hosting the current REST API session.
    [Alias('primary_cluster_id')]
    [String]$PrimaryClusterID,        
    # Oracle DB id
    [Parameter(ValueFromPipelineByPropertyName = $true)]
    [String]$id,
    # SLA id value
    [Alias('effective_sla_domain_id')]
    [String]$SLAID,    
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
    if ($SLAID.Length -eq 0 -and $SLA.Length -gt 0) {
      $SLAID = Test-RubrikSLA -SLA $SLA -Inherit $Inherit -DoNotProtect $DoNotProtect
    }
    #endregion

    $uri = New-URIString -server $Server -endpoint ($resources.URI) -id $id
    $uri = Test-QueryParam -querykeys ($resources.Query.Keys) -parameters ((Get-Command $function).Parameters.Values) -uri $uri
    $body = New-BodyString -bodykeys ($resources.Body.Keys) -parameters ((Get-Command $function).Parameters.Values)    
    $result = Submit-Request -uri $uri -header $Header -method $($resources.Method) -body $body
    $result = Test-ReturnFormat -api $api -result $result -location $resources.Result
    $result = Test-FilterObject -filter ($resources.Filter) -result $result

    # If the Get-RubrikOracleDB function has been called with the -DetailedObject parameter a separate API query will be performed if the initial query was not based on ID
    if (($DetailedObject) -and (-not $PSBoundParameters.containskey('id'))) {
      for ($i = 0; $i -lt @($result).count; $i++) {
        $Percentage = [int]($i/@($result).count*100)
        Write-Progress -Activity "DetailedObject queries in Progress, $($i+1) out of $(@($result).count)" -Status "$Percentage% Complete:" -PercentComplete $Percentage
        Get-RubrikOracleDB -id $result[$i].id
      }
    } else {
      return $result
    }

  } # End of process
} # End of function
