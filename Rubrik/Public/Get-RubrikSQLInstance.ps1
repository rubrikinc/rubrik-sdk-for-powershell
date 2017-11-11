#requires -Version 3
function Get-RubrikSQLInstance
{
  <#  
      .SYNOPSIS
      Gets internal Rubrik object that represents a SQL Server instance

      .DESCRIPTION
      Returns internal Rubrik object that represents a SQL Server instance. This 

      .NOTES
      Written by {required}
      Twitter: {optional}
      GitHub: {optional}
      Any other links you'd like here

      .LINK
      https://github.com/rubrikinc/PowerShell-Module

      .EXAMPLE
      {required: show one or more examples using the function}
  #>

  [CmdletBinding()]
  Param(
       # Name of the instance
       [Alias('InstanceName')]
       [String]$Name,
       # SLA Domain policy assigned to the database
       [String]$SLA,  
       # Name of the database host
       [String]$Hostname,
       #ServerInstance name (combined hostname\instancename)
       [String]$ServerInstance,
       # Filter the summary information based on the primarycluster_id of the primary Rubrik cluster. Use **_local** as the primary_cluster_id of the Rubrik cluster that is hosting the current REST API session.
       [Alias('primary_cluster_id')]
       [String]$PrimaryClusterID,    
       # Rubrik's database id value
       [Parameter(ValueFromPipelineByPropertyName = $true)]
       [String]$id,
       # SLA id value
       [String]$SLAID,     
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
    $resources = (Get-RubrikAPIData -endpoint $function).$api
    Write-Verbose -Message "Load API data for $($resources.Function)"
    Write-Verbose -Message "Description: $($resources.Description)"
  
    #region one-off
    if($ServerInstance){
        $SIobj = ConvertFrom-SqlServerInstance $ServerInstance
        $Hostname = $SIobj.hostname
        $Name = $SIobj.instancename
    }
    #endregion
  }

  Process {

    $uri = New-URIString -server $Server -endpoint ($resources.URI) -id $id
    $uri = Test-QueryParam -querykeys ($resources.Query.Keys) -parameters ((Get-Command $function).Parameters.Values) -uri $uri
    $body = New-BodyString -bodykeys ($resources.Body.Keys) -parameters ((Get-Command $function).Parameters.Values)
    $result = Submit-Request -uri $uri -header $Header -method $($resources.Method) -body $body
    $result = Test-ReturnFormat -api $api -result $result -location $resources.Result
    $result = Test-FilterObject -filter ($resources.Filter) -result $result

    return $result

  } # End of process
} # End of function