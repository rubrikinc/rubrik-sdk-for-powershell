#requires -Version 3
function Verb-RubrikNoun
{
  <#  
      .SYNOPSIS
      {required: high level overview}

      .DESCRIPTION
      {required: more detailed description of the function's purpose}

      .NOTES
      Written by {required}
      Twitter: {optional}
      GitHub: {optional}
      Any other links you'd like here

      .LINK
      https://github.com/rubrikinc/PowerShell-Module

      .EXAMPLE
      {required: show one or more examples using the function}
  #>

  [CmdletBinding()]
  Param(
    # {param details}
    [String]$Param1,
    # {param details}
    [String]$Param2,
    # {param details}
    [String]$Param3,    
    # Rubrik server IP or FQDN
    [String]$Server = $global:RubrikConnection.server,
    # API version
    [ValidateNotNullorEmpty()]
    [String]$api = $global:RubrikConnection.api
  )

  Begin {

    Test-RubrikConnection
        
    # {place any API reference data into the private Get-RubrikAPIData function and reference it here}
    # {no hard coded values are allowed in the function except this one}
    Write-Verbose -Message 'Gather API data'
    $resources = Get-RubrikAPIData -endpoint ('VMwareVMGet')
  
  }

  Process {

    Write-Verbose -Message 'Build the URI'
    $uri = 'https://'+$Server+$resources.$api.URI

    Write-Verbose -Message 'Build the method'
    $method = $resources.$api.Method

    try 
    {
      Write-Verbose -Message "Submitting a request to $uri"
      $r = Invoke-WebRequest -Uri $uri -Headers $Header -Method $method
    }
    catch 
    {
      throw $_
    }
      
    Write-Verbose -Message 'Formatting return value'
    $result = Test-ReturnFormat -api $api -result $result -location $resources.$api.Result

    # {anything else you need to do to the return here}
    
    return $result

  } # End of process
} # End of function
