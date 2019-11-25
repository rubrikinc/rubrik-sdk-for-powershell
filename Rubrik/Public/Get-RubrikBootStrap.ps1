#Requires -Version 3
function Get-RubrikBootStrap
{
  <#  
      .SYNOPSIS
      Connects to Rubrik cluster and retrieves the bootstrap process progress.
            
      .DESCRIPTION
      This function is created to pull the status of a cluster bootstrap request.
      
      .LINK
      https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/get-rubrikbootstrap
            
      .EXAMPLE
      Get-RubrikBootStrap -server 169.254.11.25 -requestid 1
      This will return the bootstrap status of the job with the requested ID.
  #>

  [CmdletBinding()]
  Param(
    # ID of the Rubrik cluster or me for self
    [ValidateNotNullOrEmpty()]
    [String] $id = 'me',
    # Rubrik server IP or FQDN
    [parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [String] $Server,
    # Bootstrap Request ID
    [ValidateNotNullOrEmpty()]
    [Alias('request_id')]
    [string] $RequestId = '1'
  )

  Begin {

    # The Begin section is used to perform one-time loads of data necessary to carry out the function's purpose
    # If a command needs to be run with each iteration or pipeline input, place it in the Process section
    
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

    return $result

  } # End of process
} # End of function