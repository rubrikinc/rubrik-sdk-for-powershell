#requires -Version 3
function New-RubrikManagedVolume
{
  <#  
      .SYNOPSIS
      Creates a new Rubrik Managed Volume 

      .DESCRIPTION
      The New-RubrikManagedVolume cmdlet is used to create
      a new Managed Volume

      .NOTES
      Written by Mike Fal
      Twitter: @Mike_Fal
      GitHub: MikeFal

      .LINK
      https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/new-rubrikmanagedvolume

      .EXAMPLE
      New-RubrikManagedVolume -Name foo -Channels 4 -VolumeSize 1073741824000

      Creates a new managed volume named 'foo' with 4 channels and 1073741824000 bytes (1TB) in size

      .EXAMPLE
      New-RubrikManagedVolume -Name foo -Channels 2 -VolumeSize (500 * 1GB) -Subnet 172.21.10.0/23

      Creates a new managed volume named 'foo' with 2 channels, 536870912000 bytes (500 GB) in size, on the 172.21.10.0/23 subnet

      .EXAMPLE
      New-RubrikManagedVolume -Name foo -Channels 2 -VolumeSize (500 * 1GB) -ApplicationTag "PostgreSql"

      Creates a new managed volume named 'foo' with 2 channels, 536870912000 bytes (500 GB) in size, configured for PostreSQL backups
      Valid ApplicationTag values are 'Oracle', 'OracleIncremental', 'MsSql', 'SapHana', 'MySql', 'PostgreSql', and 'RecoverX'
  #>

  [CmdletBinding()]
  Param(
    # Name of managed volume
    [Parameter(Mandatory=$true)]
    [String]$Name,
    #Number of channels in the Managed Volume
    [Parameter(Mandatory=$true)]
    [Alias('numChannels')]
    [int]$Channels,
    #Subnet Managed Volume is placed on
    [String]$Subnet,
    #Size of the Managed Volume in Bytes
    [int64]$VolumeSize,
    #Application whose data will be stored in managed volume
    [ValidateSet('Oracle', 'OracleIncremental', 'MsSql', 'SapHana', 'MySql', 'PostgreSql', 'RecoverX')]
    [string]$applicationTag,
    #Export config, such as host hints and host name patterns
    [PSCustomObject[]]$exportConfig,
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