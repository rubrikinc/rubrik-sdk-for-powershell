function Submit-Request($uri,$header,$method,$body)
{
  # The Submit-Request function is used to send data to an endpoint and then format the response for further use
  # $uri = The endpoint's URI
  # $header = The header containing authentication details
  # $method = The action (method) to perform on the endpoint
  # $body = Any optional body data being submitted to the endpoint

  try 
  {
    Write-Verbose -Message 'Submitting the request'
    # Because some calls require more than the default payload limit of 2MB, ExpandPayload dynamically adjusts the payload limit
    $result = ExpandPayload -response (Invoke-WebRequest -Uri $uri -Headers $header -Method $($resources.Method) -Body $body)
  }
  catch 
  {
    throw $_
  }
    
  return $result
}
