#requires -Version 3
function Get-RubrikUser
{
  <#  
      .SYNOPSIS
      Gets settings of a Rubrik user

      .DESCRIPTION
      The Get-RubrikUser cmdlet is used to query the Rubrik cluster to retrieve a list of settings around a Rubrik user account.

      .NOTES
      Written by Mike Preston for community usage
      Twitter: @mwpreston
      GitHub: mwpreston

      .LINK
      https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/get-rubrikuser

      .EXAMPLE
      Get-RubrikUser
      This will return settings of all of the user accounts (local and LDAP) configured within the Rubrik cluster.

      .EXAMPLE
      Get-RubrikUser -authDomainId 'local'
      This will return settings of all of the user accounts belonging to the local authoriation domain.

      .EXAMPLE
      Get-RubrikUser -username 'john.doe'
      This will return settings for the user account with the username of john.doe configured within the Rubrik cluster.
  
      .EXAMPLE
      Get-RubrikUser -authDomainId '1111-222-333'
      This will return settings of all of the user accounts belonging to the specified authoriation domain.

      .EXAMPLE
      Get-RubrikUser -id '1111-22222-33333-4444-5555'
      This will return detailed information about the user with the specified ID.
  #>

  [CmdletBinding()]
  Param(
    # Username to filter on
    [Parameter(ParameterSetName='Query')] 
    [String] $Username,
    # AuthDomainId to filter on
    [Parameter(ParameterSetName='Query')]
    [Alias('auth_domain_id')] 
    [String]$AuthDomainId,
    # User ID
    [Parameter(ParameterSetName='ID',Mandatory = $true,ValueFromPipelineByPropertyName = $true)] 
    [String]$Id,
    # Rubrik server IP or FQDN
    [Parameter(ParameterSetName='Query')]
    [Parameter(ParameterSetName='ID')]
    [String]$Server = $global:RubrikConnection.server,
    # API version
    [Parameter(ParameterSetName='Query')]
    [Parameter(ParameterSetName='ID')]
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

    # If local is passed for auth domain, get the local auth domain ID.
    if ($AuthDomainId -eq 'local') {
      $AuthDomainId = (Get-RubrikLDAP | Where-Object {$_.domainType -eq 'LOCAL'}).id
    }
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