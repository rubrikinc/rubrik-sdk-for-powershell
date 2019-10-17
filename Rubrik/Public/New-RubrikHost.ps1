#requires -Version 3
function New-RubrikHost
{
  <#  
      .SYNOPSIS
      Registers a host with a Rubrik cluster.

      .DESCRIPTION
      The New-RubrikHost cmdlet is used to register a host with the Rubrik cluster. This could be a host leveraging the Rubrik Backup Service or directly as with the case of NAS shares.

      .NOTES
      Written by Chris Wahl for community usage
      Twitter: @ChrisWahl
      GitHub: chriswahl

      .LINK
      http://rubrikinc.github.io/rubrik-sdk-for-powershell/reference/New-RubrikHost.html

      .EXAMPLE
      New-RubrikHost -Name 'Server1.example.com'
      This will register a host that resolves to the name "Server1.example.com"

      .EXAMPLE
      New-RubrikHost -Name 'NAS.example.com' -HasAgent $false
      This will register a host that resolves to the name "NAS.example.com" without using the Rubrik Backup Service
      In this case, the example host is a NAS share.
  #>

  [CmdletBinding(SupportsShouldProcess = $true,ConfirmImpact = 'High')]
  Param(
    # The IPv4 address of the host or the resolvable hostname of the host
    [Parameter(Mandatory = $true)]
    [Alias('Hostname')]
    [String]$Name,
    # Set to $false to register a host that will be accessed through network shares
    [Switch]$HasAgent,
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
    # If the switch parameter was not explicitly specified remove from query params 
    if(-not $PSBoundParameters.ContainsKey('HasAgent')) { $Resources.Body.Remove('hasAgent') }
    $uri = New-URIString -server $Server -endpoint ($resources.URI) -id $id
    $uri = Test-QueryParam -querykeys ($resources.Query.Keys) -parameters ((Get-Command $function).Parameters.Values) -uri $uri
    $body = New-BodyString -bodykeys ($resources.Body.Keys) -parameters ((Get-Command $function).Parameters.Values)
    $result = Submit-Request -uri $uri -header $Header -method $($resources.Method) -body $body
    $result = Test-ReturnFormat -api $api -result $result -location $resources.Result
    $result = Test-FilterObject -filter ($resources.Filter) -result $result

    return $result

  } # End of process
} # End of function