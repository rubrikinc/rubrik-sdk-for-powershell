#Requires -Version 3
function Get-RubrikRequest 
{
  <#  
      .SYNOPSIS
      Connects to Rubrik and retrieves details on an async request
            
      .DESCRIPTION
      The Get-RubrikRequest cmdlet will pull details on a request that was submitted to the distributed task framework.
      This is helpful for tracking the state (success, failure, running, etc.) of a request.
            
      .NOTES
      Written by Chris Wahl for community usage
      Twitter: @ChrisWahl
      GitHub: chriswahl
            
      .LINK
      http://rubrikinc.github.io/rubrik-sdk-for-powershell/
            
      .EXAMPLE
      Get-RubrikRequest -id 'MOUNT_SNAPSHOT_123456789:::0' -Type 'vmware/vm'
      Will return details about an async VMware VM request named "MOUNT_SNAPSHOT_123456789:::0"
  #>

  [CmdletBinding()]
  Param(
    # ID of an asynchronous request
    [Parameter(Mandatory = $true,ValueFromPipelineByPropertyName = $true)]
    [String]$id,
    # The type of request
    [Parameter(Mandatory = $true)]
    [ValidateSet('fileset','mssql','vmware/vm','hyperv/vm','managed_volume')]
    [String]$Type,    
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

    $uri = New-URIString -server $Server -endpoint ($resources.URI) -id $id

    #region one-off
    $uri = $uri -replace '{type}', $Type
    #Place any internal API request calls into this collection, the replace will fix the URI
    $internaltypes = @('managed_volume')
    if($internaltypes -contains $Type){
      $uri = $uri -replace 'v1', 'internal'
    }
    #endregion

    $uri = Test-QueryParam -querykeys ($resources.Query.Keys) -parameters ((Get-Command $function).Parameters.Values) -uri $uri
    $body = New-BodyString -bodykeys ($resources.Body.Keys) -parameters ((Get-Command $function).Parameters.Values)    
    $result = Submit-Request -uri $uri -header $Header -method $($resources.Method) -body $body
    $result = Test-ReturnFormat -api $api -result $result -location $resources.Result
    $result = Test-FilterObject -filter ($resources.Filter) -result $result

    return $result

  } # End of process
} # End of function