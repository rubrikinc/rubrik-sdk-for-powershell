#Requires -Version 3
function Get-RubrikClusterNetworkInterface
{
  <#  
      .SYNOPSIS
      Connects to Rubrik and retrieves the network interface details from member nodes of a Rubrik cluster.
            
      .DESCRIPTION
      The Get-RubrikClusterNetworkInterface cmdlet will retrieve the network interface details from nodes connected to a Rubrik cluster.
            
      .NOTES
      Written by Mike Preston for community usage
      Twitter: @mwpreston
      GitHub: mwpreston
            
      .LINK
      https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/get-rubrikclusternetworkinterface
            
      .EXAMPLE
      Get-RubrikClusterNetworkInterface
      This will return the details of all network interfaces on all nodes within the Rubrik cluster.
      
      .EXAMPLE
      Get-RubrikClusterNetworkInterface -Interface 'bond0'
      This will return the details of the 'bond0' interface on all nodes within the Rubrik cluster. 

      .EXAMPLE
      Get-RubrikClusterNetworkInterface -Node 'Node01'
      This will return the details of the network interfaces on the node with the id of 'Node01'
  #>

  [CmdletBinding()]
  Param(
    # Interface name to query
    [String]$interface,
    # Node id to filter results on
    [String]$Node,
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

    return $result

  } # End of process
} # End of function