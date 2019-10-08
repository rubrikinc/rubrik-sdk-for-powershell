#Requires -Version 3
function Update-RubrikVCD
{
  <#  
      .SYNOPSIS
      Connects to Rubrik and refreshes the metadata for the specified vCD Server
            
      .DESCRIPTION
      The Update-RubrikVCD cmdlet refreshes all vCD metadata known to the connected Rubrik cluster.
            
      .NOTES
      Written by Matt Eliott for community usage
      Twitter: @NetworkBrouhaha
      GitHub: shamsway

      .LINK
      http://rubrikinc.github.io/rubrik-sdk-for-powershell/
      
      .EXAMPLE
      Get-RubrikVCD -Name 'vcd.domain.local' | Update-RubrikVCD
      This will refresh the vCD metadata on the currently connected Rubrik cluster

      .EXAMPLE
      Get-RubrikVCD | Update-RubrikVCD
      This will refresh the vCD metadata for all connected vCD instances on the currently connected Rubrik cluster
  #>

  [CmdletBinding()]
  Param(
    # vCD OD value from the Rubrik Cluster
    [Parameter(
      ValueFromPipelineByPropertyName = $true,
      Mandatory = $true )]
    [ValidateNotNullOrEmpty()]
    [String]$id,
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