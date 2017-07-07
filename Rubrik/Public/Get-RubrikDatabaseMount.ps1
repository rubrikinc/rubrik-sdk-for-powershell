#Requires -Version 3
function Get-RubrikDatabaseMount
{
  <#  
      .SYNOPSIS
      Connects to Rubrik and retrieves details on mounts for a SQL Server Database
            
      .DESCRIPTION
      The Get-RubrikMount cmdlet will accept one of several different query parameters
      and retireve the database Live Mount information for that criteria.

      .NOTES
      Written by Mike Fal for community usage
      Twitter: @Mike_Fal
      GitHub: MikeFal
            
      .LINK
      https://github.com/rubrikinc/PowerShell-Module
            
      .EXAMPLE
      Get-RubrikDatabaseMount
      This will return details on all mounted databases.

      .EXAMPLE
      Get-RubrikDatabaseMount -id '11111111-2222-3333-4444-555555555555'
      This will return details on mount id "11111111-2222-3333-4444-555555555555".

      .EXAMPLE
      Get-RubrikDatabaseMount -source_database_id (Get-RubrikDatabase -HostName FOO -Instance MSSQLSERVER -Database BAR).id
      This will return details for any mounts found using the id value from a database named BAR on the FOO default instance.
                  
      .EXAMPLE
      Get-RubrikDatabaseMount -source_database_name BAR
      This returns any mounts where the source database is named BAR.

      .EXAMPLE
      Get-RubrikDatabaseMount -mounted_database_name BAR_LM
      This returns any mounts with the name BAR_LM
  #>

  [CmdletBinding()]
  Param(
    # Rubrik's id of the mount
    [Parameter(ValueFromPipelineByPropertyName = $true)]
    [String]$Id,
    # Filters live mounts by database source id
    [Alias('Source_Database_Id')]
    [String]$SourceDatabaseId,
    # Filters live mounts by database source name
    [Alias('Source_Database_Name')]
    [String]$SourceDatabaseName, 
    # Filters live mounts by database source name
    [Alias('Target_Instance_Id')]
    [String]$TargetInstanceId, 
    # Filters live mounts by database source name
    [Alias('Mounted_Database_Name','MountName')]
    [String]$MountedDatabaseName,
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
  
  }

  Process {

    $uri = New-URIString -server $Server -endpoint ($resources.URI) -id $Id
    $uri = Test-QueryParam -querykeys ($resources.Query.Keys) -parameters ((Get-Command $function).Parameters.Values) -uri $uri
    $body = New-BodyString -bodykeys ($resources.Body.Keys) -parameters ((Get-Command $function).Parameters.Values)    
    $result = Submit-Request -uri $uri -header $Header -method $($resources.Method) -body $body
    $result = Test-ReturnFormat -api $api -result $result -location $resources.Result
    $result = Test-FilterObject -filter ($resources.Filter) -result $result

    return $result

  } # End of process
} # End of function
