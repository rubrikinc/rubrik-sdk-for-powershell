#Requires -Version 3
function Get-RubrikReplicationSource
{
  <#  
      .SYNOPSIS
      Connects to Rubrik and retrieves summaries of all replication source clusters
            
      .DESCRIPTION
      The Get-RubrikReplicationSource cmdlet will retrieve summaries of all of the clusters configured as a replication source
            
      .NOTES
      Written by Mike Preston for community usage
      Twitter: @mwpreston
      GitHub: mwpreston
            
      .LINK
      https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/get-rubrikreplicationsource
            
      .EXAMPLE
      Get-RubrikReplicationSource
      This will return the details of all replication sources configured on the Rubrik cluster
    
      .EXAMPLE
      Get-RubrikReplicationSource -Name 'cluster.domain.local'
      This will return the most common details of the replication source named 'cluster.domain.local' configured on the Rubrik cluster

      .EXAMPLE
      Get-RubrikReplicationSource -Name 'cluster.domain.local' -DetailedObject
      This will return all of the the details of the replication source named 'cluster.domain.local' configured on the Rubrik cluster

      .EXAMPLE
      Get-RubrikReplicationSource -id '11111-22222-33333'
      This will return the details of the replication source with an id of '11111-22222-33333' configured on the Rubrik cluster
  #>

  [CmdletBinding()]
  Param(
    # Replication Source ID
    [ValidateNotNullOrEmpty()]
    [Parameter(
        ParameterSetName='ID',
        Position = 0,
        Mandatory = $true,
        ValueFromPipelineByPropertyName = $true)]
    [String]$Id,
    # Replication Source Cluster Name
    [ValidateNotNullOrEmpty()]
    [Parameter(
        ParameterSetName='Query',
        Position = 0,
        ValueFromPipelineByPropertyName = $true)]
    [Alias('Name')]
    [String]$sourceClusterName,
    # DetailedObject will retrieved the detailed replication source object, the default behavior of the API is to only retrieve a subset of the full replication source object unless we query directly by ID. Using this parameter does affect performance as more data will be retrieved and more API-queries will be performed.
    [Parameter(ParameterSetName='Query')]
    [Switch]$DetailedObject,
    # Rubrik server IP or FQDN
    [String]$Server = $global:RubrikConnection.server,
    # API version
    [ValidateNotNullorEmpty()]
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

    $uri = New-URIString -server $Server -endpoint ($resources.URI) -id $id
    $uri = Test-QueryParam -querykeys ($resources.Query.Keys) -parameters ((Get-Command $function).Parameters.Values) -uri $uri
    $body = New-BodyString -bodykeys ($resources.Body.Keys) -parameters ((Get-Command $function).Parameters.Values)
    $result = Submit-Request -uri $uri -header $Header -method $($resources.Method) -body $body
    $result = Test-ReturnFormat -api $api -result $result -location $resources.Result
    $result = Test-FilterObject -filter ($resources.Filter) -result $result
    $result = Set-ObjectTypeName -TypeName $resources.ObjectTName -result $result
    
    # if detailed object is passed, loop through to get more information
    if (($DetailedObject) -and (-not $PSBoundParameters.containskey('id'))) {
        for ($i = 0; $i -lt @($result).Count; $i++) {
          $Percentage = [int]($i/@($result).count*100)
          Write-Progress -Activity "DetailedObject queries in Progress, $($i+1) out of $(@($result).count)" -Status "$Percentage% Complete:" -PercentComplete $Percentage
          Get-RubrikReplicationSource -id $result[$i].sourceClusterUuid
        }
      } else {
        return $result
      }
    
  } # End of process
} # End of function