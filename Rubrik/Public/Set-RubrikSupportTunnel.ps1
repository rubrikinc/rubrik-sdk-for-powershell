#requires -Version 3
function Set-RubrikSupportTunnel
{
  <#  
      .SYNOPSIS
      Sets the configuration of the Support Tunnel

      .DESCRIPTION
      The Set-RubrikSupportTunnel cmdlet is used to update a Rubrik cluster's Support Tunnel configuration
      This tunnel is used by Rubrik's support team for providing remote assistance and is toggled on or off by the cluster administrator

      .NOTES
      Written by Chris Wahl for community usage
      Twitter: @ChrisWahl
      GitHub: chriswahl

      .LINK
      https://github.com/rubrikinc/rubrik-sdk-for-powershell

      .EXAMPLE
      Set-RubrikSupportTunnel -EnableTunnel $false
      This will disable the Support Tunnel for the Rubrik cluster

      .EXAMPLE
      Set-RubrikSupportTunnel -EnableTunnel $true
      This will enable the Support Tunnel for the Rubrik cluster and set the inactivity timeout to infinite (no timeout)

      .EXAMPLE
      Set-RubrikSupportTunnel -EnableTunnel $true -Timeout 100
      This will enable the Support Tunnel for the Rubrik cluster and set the inactivity timeout to 100 seconds
  #>

  [CmdletBinding()]
  Param(
    # Status of the Support Tunnel. Choose $true to enable or $false to disable.
    [Parameter(Mandatory = $true)]
    [Alias('isTunnelEnabled')]
    [Bool]$EnableTunnel,
    # Tunnel inactivity timeout in seconds. Only valid when setting $EnableTunnel to $true.
    [Alias('inactivityTimeoutInSeconds')]
    [int]$Timeout,    
    # Rubrik server IP or FQDN
    [String]$Server = $global:RubrikConnection.server,
    # API version
    [String]$api = $global:RubrikConnection.api
  )

  Begin {

    # The Begin section is used to perform one-time loads of data necessary to carry out the function's purpose
    # If a command needs to be run with each iteration or pipeline input, place it in the Process section
    
    # Check to ensure that a session to the Rubrik cluster exists and load the needed header data for authentication
    Test-RubrikConnection
    
    # API data references the name of the function
    # For convenience, that name is saved here to $function
    $function = $MyInvocation.MyCommand.Name
        
    # Retrieve all of the URI, method, body, query, result, filter, and success details for the API endpoint
    Write-Verbose -Message "Gather API Data for $function"
    $resources = Get-RubrikAPIData -endpoint $function
    Write-Verbose -Message "Load API data for $($resources.Function)"
    Write-Verbose -Message "Description: $($resources.Description)"
  
  }

  Process {

    $uri = New-URIString -server $Server -endpoint ($resources.URI) -id $id
    $uri = Test-QueryParam -querykeys ($resources.Query.Keys) -parameters ((Get-Command $function).Parameters.Values) -uri $uri
    $body = New-BodyString -bodykeys ($resources.Body.Keys) -parameters ((Get-Command $function).Parameters.Values)
    $result = Submit-Request -uri $uri -header $Header -method $($resources.Method) -body $body
    $result = Test-ReturnFormat -api $api -result $result -location $resources.Result
    $result = Test-FilterObject -filter ($resources.Filter) -result $result

    return $result

  } # End of process
} # End of function