#Requires -Version 3
function Get-RubrikSyslogServer
{
  <#  
      .SYNOPSIS
      Connects to Rubrik and retrieves the Syslog server settings for the currently authenticated cluster
            
      .DESCRIPTION
      The Get-RubrikSyslogServer cmdlet will retrieve the Syslog server settings for the currently authenticated cluster
            
      .NOTES
      Written by Mike Preston for community usage
      Twitter: @mwpreston
      GitHub: mwpreston
            
      .LINK
      https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/get-rubriksyslogserver
            
      .EXAMPLE
      Get-RubrikSyslogServer 
      This will return the Syslog server configuration for the authenticated Rubrik cluster.

      .EXAMPLE
      Get-RubrikSyslogServer -Name 'syslog.domain.local'
      This will return the Syslog server configuration for the syslog server named 'syslog.domain.local' for the authenticated Rubrik cluster.
  #>

  [CmdletBinding()]
  Param(
    # Syslog server hostname to retrieve settings for
    [Alias('hostname')]
    [String]$Name,
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
    $uri = Test-QueryParam -querykeys ($resources.Query.Keys) -parameters ((Get-Command $function).Parameters.Values) -uri $uri
    $body = New-BodyString -bodykeys ($resources.Body.Keys) -parameters ((Get-Command $function).Parameters.Values)
    $result = Submit-Request -uri $uri -header $Header -method $($resources.Method) -body $body
    $result = Test-ReturnFormat -api $api -result $result -location $resources.Result
    $result = Test-FilterObject -filter ($resources.Filter) -result $result

    return $result

  } # End of process
} # End of function