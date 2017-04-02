function New-BodyString($bodykeys,$parameters)
{
  # The New-BodyString function is used to create a valid body payload
  # $bodykeys = All of the body options available to the endpoint
  # $parameters = All of the parameter options available within the parent function

  # If sending a GET request, no body is needed
  if ($resources.Method -eq 'Get') 
  {
    return $null
  }
  
  Write-Verbose -Message 'Build the body parameters'
  $bodystring = @{}
  # Walk through all of the available body options presented by the endpoint
  # Note: Keys are used to search in case the value changes in the future across different API versions
  foreach ($body in $bodykeys)
  {
    # Walk through all of the parameters defined in the function
    # Both the parameter name and parameter alias are used to match against a body option
    # It is suggested to make the parameter name "human friendly" and set an alias corresponding to the body option name
    foreach ($param in $parameters)
    {
      # If the parameter name or alias matches the body option name, build a body string
      if ($param.Name -eq $body -or $param.Aliases -eq $body)
      {
        if (((Get-Variable -Name $param.Name).Value) -ne '' -and (((Get-Variable -Name $param.Name).Value).IsPresent) -ne $false) 
        {
          Write-Verbose -Message "Adding $body to body string"
          $bodystring.Add($body,(Get-Variable -Name $param.Name).Value)
        }
      }
    }
  }

  # Store the results into a JSON string
  $bodystring = ConvertTo-Json -InputObject $bodystring
  Write-Verbose -Message "Body = $bodystring"
  return $bodystring
}
