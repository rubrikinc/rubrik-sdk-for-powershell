#Requires -Version 3
function Get-RubrikSoftwareVersion
{
  <#  
      .SYNOPSIS
      Connects to Rubrik and retrieves the current software version
            
      .DESCRIPTION
      The Get-RubrikVersion cmdlet will retrieve the version of code that is actively running on the system. This does not require authentication.
            
      .NOTES
      Written by Chris Wahl for community usage
      Twitter: @ChrisWahl
      GitHub: chriswahl
            
      .LINK
      https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/Get-RubrikSoftwareVersion
            
      .EXAMPLE
      Get-RubrikSoftwareVersion -Server 192.168.1.100
      This will return the running software version on the Rubrik cluster reachable at the address 192.168.1.100
  #>

  [CmdletBinding()]
  Param(
    # Rubrik server IP or FQDN
    [Parameter(Mandatory = $true)]    
    [String]$Server,
    # ID of the Rubrik cluster or me for self
    [String]$id = 'me',
    # API version
    [ValidateNotNullorEmpty()]
    [String]$api = 'v1'
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
    $result = Submit-Request -uri $uri -method $($resources.Method) -body $body
    $result = Test-ReturnFormat -api $api -result $result -location $resources.Result
    $result = Test-FilterObject -filter ($resources.Filter) -result $result

    return $result

  } # End of process
} # End of function