#requires -Version 3
function Get-RubrikFilesetTemplate
{
  <#  
      .SYNOPSIS
      Retrieves details on one or more virtual machines known to a Rubrik cluster

      .DESCRIPTION
      The Get-RubrikVM cmdlet is used to pull a detailed data set from a Rubrik cluster on any number of virtual machines

      .NOTES
      Written by Chris Wahl for community usage
      Twitter: @ChrisWahl
      GitHub: chriswahl

      .LINK
      https://github.com/rubrikinc/PowerShell-Module

      .EXAMPLE
      Get-RubrikVM -VM 'Server1'
      This will return details on all virtual machines named "Server1".

      .EXAMPLE
      Get-RubrikVM -VM 'Server1' -SLA Gold
      This will return details on all virtual machines named "Server1" that are protected by the Gold SLA Domain.

      .EXAMPLE
      Get-RubrikVM -Relic
      This will return all removed virtual machines that were formerly protected by Rubrik.
  #>

  [CmdletBinding()]
  Param(
    # Retrieve fileset templates with a name matching the provided name. The search is performed as a case-insensitive infix search.
    [String]$Name,
    # Filter the summary information based on the primarycluster_id of the primary Rubrik cluster. Use **_local** as the primary_cluster_id of the Rubrik cluster that is hosting the current REST API session.
    [Alias('primary_cluster_id')]
    [String]$PrimaryClusterID,
    # Filter the summary information based on the operating system type of the fileset. Accepted values: 'Windows', 'Linux'
    [ValidateSet('Windows', 'Linux')]
    [Alias('operating_system_type')]
    [String]$OperatingSystemType,
    # Rubrik server IP or FQDN
    [String]$Server = $global:RubrikConnection.server,
    # API version
    [ValidateNotNullorEmpty()]
    [String]$api = $global:RubrikConnection.api
  )

  Begin {

    #region LoadOnce
    # This region is used to perform one-time loads of data necessary to carry out the function's purpose
    # If a command needs to be run with each iteration or pipeline input, place it in the Process section
    
    # Check to ensure that a session to the Rubrik cluster exists and load the needed header data for authentication
    Test-RubrikConnection
    
    # API data references the name of the function
    # For convenience, that name is saved here to $function
    $function = $MyInvocation.MyCommand.Name
        
    # Retrieve all of the URI, method, body, query, result, filter, and success details for the API endpoint
    Write-Verbose -Message "Gathering API Data for $function"
    $resources = (Get-RubrikAPIData -endpoint $function).$api
    Write-Verbose -Message "Loaded API data for $($resources.Function)"
    Write-Verbose -Message "Description: $($resources.Description)"
  
  }

  Process {

    #region URI
    # This region is used to construct the URI for communicating with the endpoint
    # If the endpoint requires an {id} value in the path, ensure that a corresponding $id param is configured for the function
    Write-Verbose -Message 'Build the URI'
    $uri = ('https://'+$Server+$resources.URI) -replace '{id}', $id
    Write-Verbose -Message "URI = $uri"
    #endregion
    
    #region Query
    # This region is used to further extend the URI to include any desired query values
    Write-Verbose -Message 'Build the query parameters'
    $querystring = @()
    # Walk through all of the available query options presented by the endpoint
    # Note: Keys are used to search in case the value changes in the future across different API versions
    foreach ($query in ($resources.Query.Keys))
    {
      # Walk through all of the parameters defined in the function
      # Both the parameter name and parameter alias are used to match against a query option
      # It is suggested to make the parameter name "human friendly" and set an alias corresponding to the query option name
      foreach ($param in ((Get-Command $function).Parameters.Values))
      {
        # If the parameter name matches the query option name, build a query string
        if ($param.Name -eq $query)
        {
          $querystring += Test-QueryObject -object (Get-Variable -Name $param.Name).Value -location $resources.Query[$param.Name] -params $querystring
        }
        # If the parameter alias matches the query option name, build a query string
        elseif ($param.Aliases -eq $query)
        {
          $querystring += Test-QueryObject -object (Get-Variable -Name $param.Name).Value -location $resources.Query[$param.Aliases] -params $querystring
        }
      }
    }
    # After all query options are exhausted, build a new URI with all defined query options
    $uri = New-QueryString -query $querystring -uri $uri -nolimit $true
    Write-Verbose -Message "URI = $uri"
    #endregion

    #region Submit
    try 
    {
      Write-Verbose -Message 'Submitting the request'
      # Because some calls require more than the default payload limit of 2MB, ExpandPayload dynamically adjusts the payload limit
      $result = ExpandPayload -response (Invoke-WebRequest -Uri $uri -Headers $Header -Method $($resources.Method))
    }
    catch 
    {
      throw $_
    }
    #endregion
    
    #region Format
    Write-Verbose -Message 'Formatting return value'
    $result = Test-ReturnFormat -api $api -result $result -location $resources.Result
    #endregion
    
    return $result

  } # End of process
} # End of function
