function Test-QueryObject($object, $location, $query) {
  <#
    .SYNOPSIS
    Builds a query string for an endpoint

    .DESCRIPTION
    The Test-QueryObject function is used to build a custom query string for supported endpoints

    .PARAMETER object
    The parent function's variable holding the user generated query data
    
    .PARAMETER location
    The key/value pair that contains the correct query name value
    
    .PARAMETER params
    An array of query values that are added based on which $objects have been passed by the user
  #>
  
  Write-Debug -Message ($PSBoundParameters | Out-String)

  if ((-not [string]::IsNullOrWhiteSpace($object)) -and ($location)) {
    # This builds the individual query item for the endpoint
    # Example: /vmware/vm?search_value=SE-CWAHL-WIN&limit=9999 contains 2 queries - search_value and limit
    if (($location -eq 'primary_cluster_id') -and ($object -in ('local','me'))) { 
      $object = $object.toLower() 
    }
    return "$location=$object"
  }
}