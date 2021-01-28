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
      Get-RubrikUser -username 'john.doe' -DetailedObject

      This will return full details of the settings for the user account with the username of john.doe configured within the Rubrik cluster.

      .EXAMPLE
      Get-RubrikUser -authDomainId '1111-222-333'

      This will return settings of all of the user accounts belonging to the specified authoriation domain.

      .EXAMPLE
      Get-RubrikUser -id '1111-22222-33333-4444-5555'

      This will return detailed information about the user with the specified ID.
  #>

  [CmdletBinding(DefaultParameterSetName = 'Query')]
  Param(
    # Username to filter on
    [Parameter(
      ParameterSetName='Query',
      Position = 0)]
    [Alias('name')]
    [String] $Username,
    # AuthDomainId to filter on
    [Parameter(ParameterSetName='Query')]
    [Alias('auth_domain_id')]
    [String]$AuthDomainId,
    # PrincipalType - For 5.3 and above
    [Parameter(ParameterSetName='Query')]
    [Parameter(ParameterSetName='ID')]
    [Parameter(DontShow)]
    [Alias('principal_type')]
    [String]$PrincipalType="User",
    # User ID
    [Parameter(
      ParameterSetName='ID',
      Position = 0,
      Mandatory = $true,
      ValueFromPipelineByPropertyName = $true)]
    [String]$Id,
    # DetailedObject will retrieved the detailed User object, the default behavior of the API is to only retrieve a subset of the full User object unless we query directly by ID. Using this parameter does affect performance as more data will be retrieved and more API-queries will be performed.
    [Switch]$DetailedObject,
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

    # if 5.3 or higher and calling with either ID we need to use the older internal endpoint...
    if (($rubrikConnection.version.substring(0,5) -as [version]) -ge [version]5.3 -and $PSBoundParameters.containskey('id') ) {
      Write-Verbose -Message "Detected 5.3 or above with ID parameter, explicitely setting endpoint"
      $uri = New-URIString -server $Server -endpoint "/api/internal/user" -id $id
    } else {
      $uri = New-URIString -server $Server -endpoint ($resources.URI) -id $id
    }

    $uri = Test-QueryParam -querykeys ($resources.Query.Keys) -parameters ((Get-Command $function).Parameters.Values) -uri $uri
    $body = New-BodyString -bodykeys ($resources.Body.Keys) -parameters ((Get-Command $function).Parameters.Values)
    $result = Submit-Request -uri $uri -header $Header -method $($resources.Method) -body $body
    $result = Test-ReturnFormat -api $api -result $result -location $resources.Result
    $result = Test-FilterObject -filter ($resources.Filter) -result $result

    # if 5.3 or higher, add username property as api has changed....
    if (($rubrikConnection.version.substring(0,5) -as [version]) -ge [version]5.3 -and ($result) -and (-not $PSBoundParameters.containskey('id')) ) {
      $result = $result | Select-Object *,@{Name="Username"; Expression={$_.name}}
    }

    if (($DetailedObject) -and (-not $PSBoundParameters.containskey('id'))) {
      for ($i = 0; $i -lt @($result).Count; $i++) {
        $Percentage = [int]($i/@($result).count*100)
        Write-Progress -Activity "DetailedObject queries in Progress, $($i+1) out of $(@($result).count)" -Status "$Percentage% Complete:" -PercentComplete $Percentage
        if ($result) {
          Get-RubrikUser -id $result[$i].id
        }
      }
    } else {
      $result = Set-ObjectTypeName -TypeName $resources.ObjectTName -result $result
      return $result
    }
  } # End of process
} # End of function