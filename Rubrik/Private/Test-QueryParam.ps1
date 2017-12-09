function Test-QueryParam($querykeys,$parameters,$uri)
{
  # The Submit-Request function is used to send data to an endpoint and then format the response for further use
  # $querykeys = All of the query options available to the endpoint
  # $parameters = All of the parameter options available within the parent function
  # $uri = The endpoint's URI
  
  # For functions that can address multiple different endpoints based on the $id value
  # If there are multiple URIs referenced in the API resources, we know this is true
  if (($resources.URI).count -ge 2)
  {  
    Write-Verbose -Message "Multiple URIs detected. Selecting URI based on $id"
    Switch -Wildcard ($id)
    {
      'Fileset:::*'
      {
        Write-Verbose -Message 'Loading Fileset API data'
        $uri = ('https://'+$Server+$resources.URI.Fileset) -replace '{id}', $id
      }
      'MssqlDatabase:::*'
      {
        Write-Verbose -Message 'Loading MSSQL API data'
        $uri = ('https://'+$Server+$resources.URI.MSSQL) -replace '{id}', $id
      }
      'VirtualMachine:::*'
      {
        Write-Verbose -Message 'Loading VMware API data'
        $uri = ('https://'+$Server+$resources.URI.VMware) -replace '{id}', $id
      }
      'HypervVirtualMachine:::*'
      {
        Write-Verbose -Message 'Loading HyperV API data'
        $uri = ('https://'+$Server+$resources.URI.HyperV) -replace '{id}', $id
      }
      default
      {
        throw 'The supplied id value has no matching endpoint'
      }
    }
    
    # This ends the logic statement without running the rest of this private function
    return $uri
  }

  Write-Verbose -Message "Build the query parameters for $($querykeys -join ',')"
  $querystring = @()
  # Walk through all of the available query options presented by the endpoint
  # Note: Keys are used to search in case the value changes in the future across different API versions
  foreach ($query in $querykeys)
  {
    # Walk through all of the parameters defined in the function
    # Both the parameter name and parameter alias are used to match against a query option
    # It is suggested to make the parameter name "human friendly" and set an alias corresponding to the query option name
    foreach ($param in $parameters)
    {
      # If the parameter name matches the query option name, build a query string
      if ($param.Name -eq $query)
      {
        $querystring += Test-QueryObject -object (Get-Variable -Name $param.Name).Value -location $resources.Query[$param.Name] -params $querystring
      }
      # If the parameter alias matches the query option name, build a query string
      elseif ($param.Aliases -eq $query)
      {
        $querystring += Test-QueryObject -object (Get-Variable -Name $param.Name).Value -location $resources.Query[$param.Aliases] -params $querystring
      }
    }
  }
  # After all query options are exhausted, build a new URI with all defined query options
  $uri = New-QueryString -query $querystring -uri $uri -nolimit $true
  Write-Verbose -Message "URI = $uri"
    
  return $uri
}
