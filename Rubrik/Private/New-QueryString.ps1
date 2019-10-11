function New-QueryString($query, $uri, $nolimit) {
  <#
    .SYNOPSIS
    Adds query parameters to a URI

    .DESCRIPTION
    This function compares the defined query parameters within Get-RubrikAPIData with any parameters set within the invocation process.
    If matches are found, a properly formatted and valid query string is created and appended to a returned URI

    .PARAMETER query
    An array of query values that are added based on which $objects have been passed by the user
    
    .PARAMETER uri
    The entire URI without any query values added
    
    .PARAMETER nolimit
    A switch for adding an inflated limit query to retrieve more than one page of results. Set to $true to activate.
  #>
  if ($nolimit -eq $true) {
    # When $nolimit is set to $true the limit query value is added to the $params array as the final item
    Write-Verbose -Message 'Query = Found limit flag'
    $query += 'limit=9999'
  }

  # TODO: It seems like there's a more elegant way to do this logic, but this code is stable and functional.
  foreach ($_ in $query) {
    # The query begins with a "?" character, which is appended to the $uri after determining that at least one $params was collected
    if ($_ -eq $query[0]) {
      $uri += '?' + $_
    }
    # Subsequent queries are separated by a "&" character
    else {
      $uri += '&' + $_
    }
  }
  return $uri
}