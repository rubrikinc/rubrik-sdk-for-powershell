#Requires -Version 3
function Remove-RubrikVolumeGroupMount
{
  <#  
      .SYNOPSIS
      Connects to Rubrik and removes one or more volume group mounts
            
      .DESCRIPTION
      The Remove-RubrikMount cmdlet is used to request the deletion of one or more volume group live mounts
            
      .NOTES
      Written by Pierre Flammer for community usage
      Twitter: @PierreFlammer
            
      .LINK
      https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/Remove-RubrikVolumeGroupMount

      .EXAMPLE
      Remove-RubrikVolumeGroupMount -id '11111111-2222-3333-4444-555555555555'
      This will remove volume mount id "11111111-2222-3333-4444-555555555555".
            
      .EXAMPLE
      Get-RubrikVolumeGroupMount | Remove-RubrikVolumeGroupMount
      This will remove all mounted volume groups.

      .EXAMPLE
      Get-RubrikVolumeGroupMount -source_host 'Server1' | Remove-RubrikVolumeGroupMount
      This will remove any volume group mounts found using the host named "Server1" as a base reference.
  #>

  [CmdletBinding(SupportsShouldProcess = $true,ConfirmImpact = 'High')]
  Param(
    # The Rubrik ID value of the mount
    [Parameter(Mandatory = $true,ValueFromPipelineByPropertyName = $true)]
    [String]$id,
    # Force unmount to deal with situations where host has been moved.
    [Switch]$Force,
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