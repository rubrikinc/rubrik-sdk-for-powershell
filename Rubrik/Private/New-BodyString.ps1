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

  # Look at the list of parameters that were set by the invocation process
  # This is how we know which params were actually set by the call, versus defaulting to some zero, null, or false value
  # We can also add any custom variables here, such as SLAID which is populated after the invocation resolves the name
  if ($slaid -and $PSCmdlet.MyInvocation.BoundParameters.ContainsKey('SLAID'))
  {
    $PSCmdlet.MyInvocation.BoundParameters.SLAID = $slaid
  } 
  elseif($slaid)
  {
    $PSCmdlet.MyInvocation.BoundParameters.Add('SLAID',$slaid)
  }
  
  # Now that custom params are added, let's inventory all invoked params
  $setParameters = $pscmdlet.MyInvocation.BoundParameters
  Write-Verbose -Message "List of set parameters: $($setParameters.GetEnumerator())"

  Write-Verbose -Message 'Build the body parameters'
  $bodystring = @{}
  # Walk through all of the available body options presented by the endpoint
  # Note: Keys are used to search in case the value changes in the future across different API versions
  foreach ($body in $bodykeys)
  {
    Write-Verbose "Adding $body..."
    # Array Object
    if ($resources.Body.$body.GetType().BaseType.Name -eq 'Array')
    {
      Write-Verbose "Body Build Debug: Detected array Object"
      $bodyarray = $resources.Body.$body.Keys
      $arraystring = @{}
      foreach ($arrayitem in $bodyarray) 
      {
        # Walk through all of the parameters defined in the function
        # Both the parameter name and parameter alias are used to match against a body option
        # It is suggested to make the parameter name "human friendly" and set an alias corresponding to the body option name
        foreach ($param in $parameters)
        {
          # If the parameter name or alias matches the body option name, build a body string
          
          if ($param.Name -eq $arrayitem -or $param.Aliases -eq $arrayitem)
          {
            # Switch variable types
            if ((Get-Variable -Name $param.Name).Value.GetType().Name -eq 'SwitchParameter')
            {
              $arraystring.Add($arrayitem,(Get-Variable -Name $param.Name).Value.IsPresent)
            }
            # All other variable types
            elseif ($null -ne (Get-Variable -Name $param.Name).Value)
            {
              $arraystring.Add($arrayitem,(Get-Variable -Name $param.Name).Value)
            }
          }
        }
      }
      $bodystring.Add($body,@($arraystring))
    }

    # Non-Array Object
    else 
    {
      Write-Verbose "Body Build Debug: Detected non-array Object"
      # Walk through all of the parameters defined in the function
      # Both the parameter name and parameter alias are used to match against a body option
      # It is suggested to make the parameter name "human friendly" and set an alias corresponding to the body option name
      foreach ($param in $parameters)
      {
        # If the parameter name or alias matches the body option name, build a body string
        if (($param.Name -eq $body -or $param.Aliases -eq $body) -and $setParameters.ContainsKey($param.Name))
        {
          # Switch variable types
          if ((Get-Variable -Name $param.Name).Value.GetType().Name -eq 'SwitchParameter')
          {
            $bodystring.Add($body,(Get-Variable -Name $param.Name).Value.IsPresent)
          }     
          # All other variable types
          elseif ($null -ne (Get-Variable -Name $param.Name).Value -and (Get-Variable -Name $param.Name).Value.Length -gt 0)
          {
            $bodystring.Add($body,(Get-Variable -Name $param.Name).Value)
          }
        }
      }
    }
  }

  # Store the results into a JSON string
  $bodystring = ConvertTo-Json -InputObject $bodystring -depth 3
  Write-Verbose -Message "Body = $bodystring"
  return $bodystring
}
