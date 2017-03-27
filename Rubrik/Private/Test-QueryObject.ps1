function Test-QueryObject($object,$location,$query)
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