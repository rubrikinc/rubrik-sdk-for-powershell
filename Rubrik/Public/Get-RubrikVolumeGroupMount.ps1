#Requires -Version 3
function Get-RubrikVolumeGroupMount
{
  <#  
      .SYNOPSIS
      Connects to Rubrik and retrieves details on mounts of volume groups
            
      .DESCRIPTION
      The Get-RubrikVolumeGroupMount cmdlet will accept a volume group id or the name of the source_host.
      It returns details on any mount operations that are active within Rubrik.
            
      .NOTES
      Written by Pierre Flammer for community usage
      Twitter: @PierreFlammer
            
      .LINK
      https://github.com/rubrikinc/rubrik-sdk-for-powershell
            
      .EXAMPLE
      Get-RubrikVolumeGroupMount
      This will return details on all mounted volume groups.

      .EXAMPLE
      Get-RubrikVolumeGroupMount -id '11111111-2222-3333-4444-555555555555'
      This will return details on mount id "11111111-2222-3333-4444-555555555555".

      .EXAMPLE
      Get-RubrikVolumeGroupMount -source_host win-server01
      This will return details for any mounts found where the source host is win-server01
                  
      .EXAMPLE
      Get-RubrikVolumeGroupMount | Where-Object {$_.targetHostName -eq 'recover-01'}
      This will return details for any mounts found that are mounted on the server recover-01
  #>

  [CmdletBinding()]
  Param(
    # Rubrik's id of the mount
    [Parameter(ValueFromPipelineByPropertyName = $true)]
    [String]$id,
    # Filters live mounts by VM ID
    [String]$source_host,
    # Rubrik server IP or FQDN
    [String]$Server = $global:RubrikConnection.server,
    # API version
    [ValidateNotNullorEmpty()]
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
