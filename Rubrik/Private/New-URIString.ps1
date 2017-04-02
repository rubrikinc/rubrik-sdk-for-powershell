function New-URIString($server,$endpoint,$id)
{
  # The New-URIString function is used to build a valid URI
  # $server = The Rubrik cluster IP or FQDN
  # $endpoint = The endpoint path
  # $id = An id value to be planted into the path or optionally at the end of the URI to retrieve a single object

  Write-Verbose -Message 'Build the URI'
  # If we find {id} in the path, replace it with the $id value  
  if ($endpoint.Contains('{id}'))
  {
    $uri = ('https://'+$server+$endpoint) -replace '{id}', $id
  }
  # Otherwise, only add the $id value at the end if it exists (for single object retrieval)
  else
  {
    $uri = 'https://'+$server+$endpoint
    if ($id) 
    {
      $uri += "/$id"
    }
  }
  Write-Verbose -Message "URI = $uri"
    
  return $uri
}
