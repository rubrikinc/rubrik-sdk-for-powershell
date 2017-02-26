function Test-QueryObject($object,$location,$params)
{
  # The Test-QueryObject function is used to build a custom query string for supported endpoints
  # $object = The parent function's variable holding the user generated query data
  # $location = The key/value pair that contains the correct query name value
  # $params = An array of query values that are added based on which $objects have been passed by the user
  
  if ($object -and $location)
  {
    # This builds the individual query item for the endpoint
    # Example: /vmware/vm?search_value=SE-CWAHL-WIN&limit=9999 contains 2 queries - search_value and limit
    return "$location=$object"
  }
}

function New-QueryString($params,$uri,$nolimit)
{
  # The New-QueryString function is used to collect an array of query values and combine them into a valid URI
  # $params = An array of query values that are added based on which $objects have been passed by the user
  # $uri = The entire URI without any query values added
  # $nolimit = A switch for adding an inflated limit query to retrieve more than one page of results. Set to $true to activate.

  if ($nolimit -eq $true) 
  {
    # When $nolimit is set to $true the limit query value is added to the $params array as the final item
    $params += 'limit=9999'
  }

  # TODO: It seems like there's a more elegant way to do this logic, but this code is stable and functional.
  foreach ($_ in $params)
  {
    # The query begins with a "?" character, which is appended to the $uri after determining that at least one $params was collected
    if ($_ -eq $params[0]) 
    {
      $uri += '?'+$_
    }
    # Subsequent queries are separated by a "&" character
    else 
    {
      $uri += '&'+$_
    }
  }
  return $uri
}

function Test-ReturnFormat($api,$result,$location)
{
  # The Test-ReturnFormat function is used to remove any parent variables surrounding return data, such as encapsulating results in a "data" key
  # $api = The API version
  # $result = The unformatted API response content
  # $location = The key/value pair that contains the name of the key holding the response content's data

  if ($location) 
  {
    # The $location check assumes that not all endpoints will require findng (and removing) a parent key
    # If one does exist, this extracts the value so that the $result data is consistent across API versions
    return ($result).$location
  }
  else
  {
    # When no $location is found, return the original $result
    return $result
  }
}

function Test-ReturnFilter($object,$location,$result)
{
  # The Test-ReturnFilter function is used to perform a search across response content for a particular value
  # $object = The parent function's variable holding the user generated query data
  # $location = The key/value pair that contains the name of the key holding the data to filter through
  # $result = The unfiltered API response content
  
  if ($object)
  {
    # The $object check assumes that not all filters will be used in each call
    # If it does exist, the results are filtered using the $object's value against the $location's key name
    # Example: Filtering an SLA Domain Name based on the "effectiveSlaDomainName" key/value pair
    return $result | Where-Object -FilterScript {
      ($result).$location -eq $object
    }
  }
  else
  {
    # When no $location is found, return the original $result
    return $result
  }
}
