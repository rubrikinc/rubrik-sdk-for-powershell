function Test-ReturnFormat($api, $result, $location) {
  <#
    .SYNOPSIS
    Removes parent encapsulation from returned responses

    .DESCRIPTION
    The Test-ReturnFormat function is used to remove any parent variables surrounding return data, such as encapsulating results in a "data" key

    .PARAMETER api
    The API version
    
    .PARAMETER result
    The unformatted API response content

    .PARAMETER location
    The key/value pair that contains the name of the key holding the response content's data
  #>

  Write-Verbose -Message 'Formatting return value'
  if ($location -and ($null -ne ($result).$location)) {
    # The $location check assumes that not all endpoints will require findng (and removing) a parent key
    # If one does exist, this extracts the value so that the $result data is consistent across API versions
    return ($result).$location
  }
  else {
    # When no $location is found, return the original $result
    return $result
  }
}
