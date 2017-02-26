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
      $_.$location -eq $object
    }
  }
  else
  {
    # When no $location is found, return the original $result
    return $result
  }
}
