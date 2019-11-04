#Requires -Version 3
function Get-RubrikProxySetting
{
  <#  
    .SYNOPSIS
    Retrieves a Rubrik Cluster proxy config
        
    .DESCRIPTION
    The Get-RubrikProxySetting cmdlet will retrieve proxy configuration information for the cluster nodes.
        
    .NOTES
    Written by Jaap Brasser for community usage
    Twitter: @jaap_brasser
    GitHub: jaapbrasser
        
    .LINK
    https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/Get-RubrikProxySetting
        
    .EXAMPLE
    Get-RubrikProxySetting 
    This will return the proxy information for the node currently connected to
      
    .EXAMPLE
    Get-RubrikNode | Get-RubrikProxySetting 
    This will return the proxy information for all nodes connected to the current Rubrik Cluster
  #>

  [CmdletBinding()]
  Param(
    # Rubrik server IP or FQDN
    [Parameter(
        ValueFromPipelineByPropertyName = $true)]
    [Alias('ipAddress')]
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

    $result = $result | Select-Object -Property *,@{
        name = 'NodeIPAddress'
        expression = {
            $server
        }
    }
    
    $result = Set-ObjectTypeName -TypeName $resources.ObjectTName -result $result
    
    return $result

  } # End of process
} # End of function