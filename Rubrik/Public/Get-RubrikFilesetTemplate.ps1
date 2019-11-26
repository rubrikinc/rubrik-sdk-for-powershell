#requires -Version 3
function Get-RubrikFilesetTemplate
{
  <#  
      .SYNOPSIS
      Retrieves details on one or more fileset templates known to a Rubrik cluster

      .DESCRIPTION
      The Get-RubrikFilesetTemplate cmdlet is used to pull a detailed data set from a Rubrik cluster on any number of fileset templates

      .NOTES
      Written by Chris Wahl for community usage
      Twitter: @ChrisWahl
      GitHub: chriswahl

      .LINK
      https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/get-rubrikfilesettemplate

      .EXAMPLE
      Get-RubrikFilesetTemplate -Name 'Template1'
      This will return details on all fileset templates named "Template1"

      .EXAMPLE
      Get-RubrikFilesetTemplate -OperatingSystemType 'Linux'
      This will return details on all fileset templates that can be used against a Linux operating system type

      .EXAMPLE
      Get-RubrikFilesetTemplate -id '11111111-2222-3333-4444-555555555555'
      This will return details on the fileset template matching id "11111111-2222-3333-4444-555555555555"
  #>

  [CmdletBinding()]
  Param(
    # Retrieve fileset templates with a name matching the provided name. The search is performed as a case-insensitive infix search.
    [Alias('FilesetTemplate')]
    [String]$Name,
    # Filter the summary information based on the operating system type of the fileset. Accepted values: 'Windows', 'Linux'
    [ValidateSet('Windows', 'Linux')]
    [Alias('operating_system_type')]
    [String]$OperatingSystemType,
    # Filter the summary information based on the share type of the fileset. Accepted values: 'NFS', 'SMB'
    [ValidateSet('NFS', 'SMB')]
    [Alias('share_type')]
    [String]$shareType,
    # Filter the summary information based on the primarycluster_id of the primary Rubrik cluster. Use 'local' as the primary_cluster_id of the Rubrik cluster that is hosting the current REST API session.
    [Alias('primary_cluster_id')]
    [String]$PrimaryClusterID,    
    # The ID of the fileset template
    [Parameter(ValueFromPipelineByPropertyName = $true)]    
    [String]$id,
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
    $result = Set-ObjectTypeName -TypeName $resources.ObjectTName -result $result
    
    return $result

  } # End of process
} # End of function