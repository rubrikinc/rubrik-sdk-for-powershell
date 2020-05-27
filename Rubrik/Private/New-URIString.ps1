function New-URIString($server, $endpoint, $id) {
  <#
    .SYNOPSIS
    Builds a valid URI

    .DESCRIPTION
    Builds a valid URI based off of the constructs defined in the Get-RubrikAPIData resources for the cmdlet.
    Inserts any object IDs into the URI if {id} is specified within the constructs.

    .PARAMETER server
    The Rubrik cluster IP or FQDN
    
    .PARAMETER endpoint
    The endpoint path
    
    .PARAMETER id
    An id value to be planted into the path or optionally at the end of the URI to retrieve a single object
  #>

  # Validation of id param
  if ($id -match '^@\{') {
    Write-Error -Message "Please validate ID input, please only input the ID parameter the object: '$id'" -ErrorAction Stop
  } elseif ($id.Length -gt 100) {
    Write-Error -Message "Please validate ID input, invalid ID provided: '$id'" -ErrorAction Stop
  }

  Write-Verbose -Message 'Build the URI'
  # If we find {id} in the path, replace it with the $id value  
  if ($endpoint.Contains('{id}')) {
    $uri = ('https://' + $server + $endpoint) -replace '{id}', $id
  }
  # Otherwise, only add the $id value at the end if it exists (for single object retrieval)
  else {
    $uri = 'https://' + $server + $endpoint
    if ($id) {
      $uri += "/$id"
    }
  }
  Write-Verbose -Message "URI = $uri"
    
  return $uri
}
