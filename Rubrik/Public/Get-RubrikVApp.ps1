#Requires -Version 3
function Get-RubrikVApp
{
  <#  
      .SYNOPSIS
      Connects to Rubrik and retrieves the current Rubrik vCD vApp settings
            
      .DESCRIPTION
      The Get-RubrikVApp cmdlet retrieves all the vCD vApp settings actively running on the system. This requires authentication with your Rubrik cluster.
            
      .NOTES
      Written by Matt Elliott for community usage
      Twitter: @NetworkBrouhaha
      GitHub: shamsway
            
      .LINK
      https://github.com/rubrikinc/PowerShell-Module

      .EXAMPLE
      Get-RubrikDatabase
      This will return details on all vCD vApps that are currently or formerly protected by Rubrik.

      .EXAMPLE
      Get-RubrikVApp -Name 'vApp01'
      This will return details on all vCD vApps named "vApp01".

      .EXAMPLE
      Get-RubrikVApp -Name 'Server1' -SLA 'Gold'
      This will return details on all vCD vApps named "Server1" that are protected by the Gold SLA Domain.

      .EXAMPLE
      Get-RubrikVApp -Relic
      This will return all removed vCD vApps that were formerly protected by Rubrik.
      
      .EXAMPLE
      Get-RubrikVApp -Relic:false
      This will return all vCD vApps that are currently protected by Rubrik.

      .EXAMPLE
      Get-RubrikVApp -SourceObjectId 'VcdVapp:::01234567-8910-1abc-d435-0abc1234d567'
      This will return details on all vCD vApps with the Source Object ID  "VcdVapp:::01234567-8910-1abc-d435-0abc1234d567"

      .EXAMPLE
      Get-RubrikVApp -vcdClusterId 'Vcd:::01234567-8910-1abc-d435-0abc1234d567'
      This will return details on all vCD vApps on the vCD Cluster with id "Vcd:::01234567-8910-1abc-d435-0abc1234d567"
  #>

  [CmdletBinding(DefaultParameterSetName = 'Query')]
  Param(
    # Name of the vCD vApp
    [Parameter(
      ParameterSetName='Query',
      Position = 0,
      ValueFromPipelineByPropertyName = $true)]
    [ValidateNotNullOrEmpty()]
    [Alias('VM')]
    [String]$Name,
    # vCD vApp id
    [Parameter(
      ParameterSetName='ID',
      Position = 0,
      Mandatory = $true,
      ValueFromPipelineByPropertyName = $true)]
    [ValidateNotNullOrEmpty()]
    [String]$id,
    # Filter results to include only relic (removed) vCD vApps
    [Parameter(ParameterSetName='Query')]
    [Alias('is_relic')]    
    [Switch]$Relic,
    # DetailedObject will retrieved the detailed vApp object, the default behavior of the API is to only retrieve a subset of the full vApp object unless we query directly by ID. Using this parameter does affect performance as more data will be retrieved and more API-queries will be performed.
    [Parameter(ParameterSetName='Query')]
    [Switch]$DetailedObject,
    # SLA Domain policy assigned to the vCD vApp
    [Parameter(ParameterSetName='Query')]
    [ValidateNotNullOrEmpty()]
    [String]$SLA, 
    # Filter by SLA Domain assignment type
    [Parameter(ParameterSetName='Query')]
    [ValidateNotNullOrEmpty()]
    [ValidateSet('Derived', 'Direct','Unassigned')]
    [Alias('sla_assignment')]
    [String]$SLAAssignment,     
    # Filter the summary information based on the primarycluster_id of the primary Rubrik cluster. Use **local** as the primary_cluster_id of the Rubrik cluster that is hosting the current REST API session.
    [Parameter(ParameterSetName='Query')]
    [ValidateNotNullOrEmpty()]
    [Alias('primary_cluster_id')]
    [String]$PrimaryClusterID,        
    # SLA id value
    [Parameter(ParameterSetName='Query')]
    [ValidateNotNullOrEmpty()]
    [Alias('effective_sla_domain_id')]
    [String]$SLAID,
    # ID of Source Object in terms of vCD Hierarchy
    [Parameter(ParameterSetName='Query')]
    [Parameter(ParameterSetName='ID')]
    [ValidateNotNullOrEmpty()]
    [String]$SourceObjectId,
    # Name of Source Object in terms of vCD Hierarchy
    [Parameter(ParameterSetName='Query')]
    [Parameter(ParameterSetName='ID')]
    [ValidateNotNullOrEmpty()]
    [String]$SourceObjectName,
    # ID of vCD Cluster
    [Parameter(ParameterSetName='Query')]
    [Parameter(ParameterSetName='ID')]
    [ValidateNotNullOrEmpty()]
    [String]$vcdClusterId,
    # Name of vCD Cluster
    [Parameter(ParameterSetName='Query')]
    [Parameter(ParameterSetName='ID')]
    [ValidateNotNullOrEmpty()]
    [String]$vcdClusterName,
    # Rubrik server IP or FQDN
    [Parameter(ParameterSetName='Query')]
    [Parameter(ParameterSetName='ID')]
    [String]$Server = $global:RubrikConnection.server,
    # API version
    [Parameter(ParameterSetName='Query')]
    [Parameter(ParameterSetName='ID')]
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

    # If the Get-RubrikVApp function has been called with the -DetailedObject parameter a separate API query will be performed if the initial query was not based on ID
    if (($DetailedObject) -and (-not $PSBoundParameters.containskey('id'))) {
      for ($i = 0; $i -lt @($result).Count; $i++) {
        $Percentage = [int]($i/@($result).count*100)
        Write-Progress -Activity "DetailedObject queries in Progress, $($i+1) out of $(@($result).count)" -Status "$Percentage% Complete:" -PercentComplete $Percentage
        Get-RubrikVApp -id $result[$i].id
      }
    } else {
      return $result
    }

  } # End of process
} # End of function
