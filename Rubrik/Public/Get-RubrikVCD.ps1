#Requires -Version 3
function Get-RubrikVCD
{
  <#  
      .SYNOPSIS
      Connect to Rubrik and retrieve the current Rubrik vCD settings
            
      .DESCRIPTION
      The Get-RubrikVCD cmdlet retrieves all vCD settings actively running on the system. This requires authentication.
            
      .NOTES
      Written by Matt Elliott for community usage
      Twitter: @NetworkBrouhaha
      GitHub: shamsway
            
      .LINK
      https://github.com/rubrikinc/PowerShell-Module
            
      .EXAMPLE
      Get-RubrikVCD
      This returns the vCD settings on the currently connected Rubrik cluster

      .EXAMPLE
      Get-RubrikVCD -Name 'My vCD Cluster'
      This returns the vCD settings on the currently connected Rubrik cluster matching the name 'My vCD Cluster'

      .EXAMPLE
      Get-RubrikVCD -Hostname 'vcd.example.com'
      This returns the vCD settings on the currently connected Rubrik cluster matching the hostname 'vcd.example.com'

      .EXAMPLE
      Get-RubrikVCD -Status 'Connected'
      This returns the vCD settings on the currently connected Rubrik cluster with the status of 'Connected'
  #>

  [CmdletBinding()]
  Param(
    # vCD Cluster Name
    [ValidateNotNullOrEmpty()]
    [String]$Name,
    # vCD Cluster Hostname
    [ValidateNotNullOrEmpty()]
    [String]$Hostname,
    # vCD Cluster Status
    [ValidateSet('Disconnected', 'Refreshing','Connected','BadlyConfigured','Deleting','Remote')]
    [String]$Status,
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

    return $result

  } # End of process
} # End of function