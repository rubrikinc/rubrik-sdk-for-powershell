#requires -Version 3
function Get-RubrikOrgAuthorization
{
  <#  
      .SYNOPSIS
      Returns a list of authorizations for the organization role.

      .DESCRIPTION
      This cmdlet returns the current list of authorizations for the organization role. Organizations are used to support
      Rubrik's multi-tenancy feature. 

      .NOTES
      Written by Matt Elliott for community usage
      Twitter: @NetworkBrouhaha
      GitHub: shamsway
      
      .LINK
      https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/Get-RubrikOrgAuthorization

      .EXAMPLE
      Get-RubrikOrgAuthorization
      Infers the Organization of the current user and returns the list of authorizations for that Organization.

      .EXAMPLE
      Get-RubrikOrgAuthorization -ID Organization:::01234567-8910-1abc-d435-0abc1234d567
      Returns the list of authorizations for the Organization with ID Organization:::01234567-8910-1abc-d435-0abc1234d567

      .EXAMPLE
      Get-RubrikOrganization | Get-RubrikOrgAuthorization
      Returns a list of authorizations for all organizations on the current cluster
  #>

  [CmdletBinding()]
  Param(
    # Principal ID
    [Parameter(ValueFromPipelineByPropertyName = $true)]
    [Alias('principals')]
    [String]$id,
    # Organization ID
    [Alias('organization_id')]
    [String]$OrgID,
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
    #region One-off
    # If ID was not specified, get the current user ID. This is used to infer the Org ID to query.
    if([string]::IsNullOrEmpty($id)) { 
      $id = (Get-RubrikUser -id me).id
      Write-Verbose "Using User ID $($id) as principal. This will infer the Organization ID automatically."
    } elseif([string]::IsNullOrEmpty($PSBoundParameters.OrgID)) {
    # Unless specified and not using an inferred Org ID, API expects principal (ID) and Org ID to be the same
      $OrgID = $id
    }
    #endregion
    
    $uri = New-URIString -server $Server -endpoint ($resources.URI)
    $uri = Test-QueryParam -querykeys ($resources.Query.Keys) -parameters ((Get-Command $function).Parameters.Values) -uri $uri
    $body = New-BodyString -bodykeys ($resources.Body.Keys) -parameters ((Get-Command $function).Parameters.Values)
    $result = Submit-Request -uri $uri -header $Header -method $($resources.Method) -body $body
    $result = Test-ReturnFormat -api $api -result $result -location $resources.Result
    $result = Test-FilterObject -filter ($resources.Filter) -result $result

    # Add pre-work for custom formatting
    $result = $result | Select-Object -Property *,@{
      name = 'orgname'
      expression = {
        (Get-RubrikOrganization -id $_.organizationId).Name
      }
    },@{
      name = 'manageCluster'
      expression = {
        $_.privileges.manageCluster
      }
    },@{
      name = 'useSla'
      expression = {
        $_.privileges.useSla
      }
    },@{
      name = 'manageResource'
      expression = {
        $_.privileges.manageResource
      }
    },@{
      name = 'manageSla'
      expression = {
        $_.privileges.manageSla
      }
    }

    $result = Set-ObjectTypeName -TypeName $resources.ObjectTName -result $result
    return $result

  } # End of process
} # End of function