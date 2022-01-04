#requires -Version 3
function Find-RubrikFile
{
  <#
      .SYNOPSIS
      Searches snapshots for files within a Rubrik protected object. 

      .DESCRIPTION
      The Find-RubrikFile cmdlet uses the internal search API to find files within snapshots of protected objects 

      .NOTES
      Written by Jake Robinson for community usage
      Twitter: @jakerobinson
      GitHub: jakerobinson

      .LINK
      https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/find-rubrikfile

      .EXAMPLE
      Get-RubrikVM -Sla Gold | Find-RubrikFile -SearchString "pizza"
      This example will search all VM snapshots in the Gold SLA for a filename containing "pizza"

      .EXAMPLE
      Get-RubrikFileset -HostName MyVM | Find-RubrikFile -SearchString "pancake"
      This example will search filesets for the VM "MyVM" for a filename containing "pancake"
  #>

  [CmdletBinding(DefaultParameterSetName = 'Query')]
  Param(
    # ID of the object to search
    [ValidateNotNullOrEmpty()]
    [Parameter(
        ParameterSetName='Query',
        Position = 0,
        Mandatory = $true,
        ValueFromPipeline = $true,
        ValueFromPipelineByPropertyName = $true)]
    [String]$id,
    # String to search for in filename
    [ValidateNotNullOrEmpty()]
    [Parameter(
        ParameterSetName='Query',
        Position = 1)]
    [String]$SearchString,
    # Limit the number of search results (API defaults to 100)
    [Parameter(
        ParameterSetName='Query',
        Position = 2)]
    [String]$Limit,
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
    
    $uri = New-URIString -server $Server -endpoint ($resources.URI)
    $uri = Test-QueryParam -querykeys ($resources.Query.Keys) -parameters ((Get-Command $function).Parameters.Values) -uri $uri
    $body = New-BodyString -bodykeys ($resources.Body.Keys) -parameters ((Get-Command $function).Parameters.Values)
    $result = Submit-Request -uri $uri -header $Header -method $($resources.Method) -body $body
    $result = Test-ReturnFormat -api $api -result $result -location $resources.Result
    $result = Test-FilterObject -filter ($resources.Filter) -result $result
    $result = Set-ObjectTypeName -TypeName $resources.ObjectTName -result $result

    # The Search API does not include the object we just searched, because it assumes we know since we were the one that called it.
    # However, in this case the user does not know since we are piping a number of objects into the search,
    # so we are adding additional properties to the search result object so that the user knows the objects on which these files exist.
    if ($result){
        $managedObject = $_
        $result | Add-Member -MemberType NoteProperty -Name 'ObjectId' -Value $managedObject.id
        $result | Add-Member -MemberType NoteProperty -Name 'ObjectName' -Value $managedObject.name
    }

    $result

  } # End of process
} # End of function