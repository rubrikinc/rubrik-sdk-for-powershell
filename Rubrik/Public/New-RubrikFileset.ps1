#requires -Version 3
function New-RubrikFileset
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
      https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/New-RubrikFileset

      .EXAMPLE
      New-RubrikFileset -TemplateID '1111-1111-1111-1111' -HostID 'Host::::2222-2222-2222-2222'

      Creates a new fileset on the specified host, using the selected template.

      .EXAMPLE
      New-RubrikFileset -TemplateID (Get-RubrikFilesetTemplate -Name 'FOO').id -ShareID (Get-RubrikNASShare -name 'BAR').id

      Creates a new fileset for the BAR NAS, using the FOO template.
  #>

  [CmdletBinding()]
  Param(
    #Fileset Template ID to use for the new fileset
    [Parameter(Mandatory=$true)]
    [String]$TemplateID,
    # HostID - Used for Windows or Linux Filesets
    [String]$HostID,
    # ShareID - used for NAS shares
    [String]$ShareID,   
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