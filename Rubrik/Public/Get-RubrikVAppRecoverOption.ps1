#requires -Version 3
function Get-RubrikVAppRecoverOption
{
  <#  
      .SYNOPSIS
      Retrieves instant recovery options a vCD vApp known to a Rubrik cluster

      .DESCRIPTION
      The Get-RubrikVAppRecoverOption cmdlet is used to retrieve instant recovery options for a vCD vApp known to a Rubrik cluster

      .NOTES
      Written by Matt Elliott for community usage
      Twitter: @NetworkBrouhaha
      Github: shamsway

      .LINK
      https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/Get-RubrikVAppRecoverOption

      .EXAMPLE
      $SnapshotID = (Get-RubrikVApp -Name 'vApp01' | Get-RubrikSnapshot -Latest).id
      Get-RubrikVAppRecoverOption -id $SnapshotID
      This will return recovery options on the specific snapshot.
  #>

  [CmdletBinding()]
  Param(
    # Snapshot ID of the vApp to retrieve options for
    [Parameter(ValueFromPipelineByPropertyName = $true)]
    [ValidateNotNullOrEmpty()]
    [Alias('snapshot_id')]
    [String]$id,
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
