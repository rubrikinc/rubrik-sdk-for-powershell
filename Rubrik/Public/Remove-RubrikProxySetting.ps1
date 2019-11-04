#requires -Version 3
function Remove-RubrikProxySetting
{
  <#  
    .SYNOPSIS
    Removes Proxy Configuration from a Rubrik node 

    .DESCRIPTION
    Removes Proxy Configuration for either the current node or the specified node

    .NOTES
    Written by Jaap Brasser for community usage
    Twitter: @jaap_brasser
    GitHub: jaapbrasser
    
    .LINK
    https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/Remove-RubrikProxySetting
    
    .EXAMPLE
    Remove-RubrikProxySetting
    
    Removes the Rubrik Node Proxy Configuration for the current node
    
    .EXAMPLE
    Get-RubrikNodeProxyConfig | Remove-RubrikProxySetting -Verbose
    
    Removes the current Rubrik Node Proxy configuration while displaying Verbose information
    
    .EXAMPLE
    Get-RubrikNode | Remove-RubrikProxySetting
    
    Removes the Proxy configuration for all Rubrik Nodes retrieved by Get-RubrikNode
  #>

  [CmdletBinding(SupportsShouldProcess = $true,ConfirmImpact = 'High')]
  Param(
    # Rubrik server IP or FQDN
    [Parameter(
        ValueFromPipelineByPropertyName = $true)]
    [Alias('ipAddress','NodeIPAddress')]
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