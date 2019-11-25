#requires -Version 3
function Set-RubrikOrgAuthorization
{
  <#  
      .SYNOPSIS
      Assigns a list of authorizations to an organization.

      .DESCRIPTION
      This cmdlet is used to assign authorization to an organization. Organizations are used to support
      Rubrik's multi-tenancy feature.

      -UseSLA, -ManageResource, and -ManageSLA can be passed a string, or an array of strings containing the desired IDs.

      .NOTES
      Written by Matt Elliott for community usage
      Twitter: @NetworkBrouhaha
      GitHub: shamsway
      
      .LINK
      https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/set-rubrikorgauthorization

      .EXAMPLE
      Set-RubrikOrgAuthorization -ID 'Organization:::01234567-8910-1abc-d435-0abc1234d567' -UseSLA '12345678-1234-abcd-8910-1234567890ab' 
      Authorizes the Organization with ID Organization:::01234567-8910-1abc-d435-0abc1234d567 to use the SLA Domain with ID 12345678-1234-abcd-8910-1234567890ab

      .EXAMPLE
      Set-RubrikOrgAuthorization -ID 'Organization:::01234567-8910-1abc-d435-0abc1234d567' -ManageResource 'VirtualMachine:::aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee-vm-12345' 
      Authorizes the Organization with ID Organization:::01234567-8910-1abc-d435-0abc1234d567 to manage the VM with ID VirtualMachine:::aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee-vm-12345

      .EXAMPLE
      $vms = (Get-RubrikVM -PrimaryClusterId local -Relic:$false | Where-Object { $_.Name -like '*sql*' }).id
      Set-RubrikOrgAuthorization -ID 'Organization:::01234567-8910-1abc-d435-0abc1234d567' -ManageResource $vms
      Authorizes the Organization with ID Organization:::01234567-8910-1abc-d435-0abc1234d567 to manage all VMs with names containing the string 'SQL'
  #>

  [CmdletBinding()]
  Param(
    # Principal ID
    [Parameter(Mandatory = $true,ValueFromPipelineByPropertyName = $true)]
    [Alias('principals')]
    [String]$id,
    # Organization ID
    [Alias('organization_id')]
    [String]$OrgID,
    # Use SLAs. Must be an SLA ID.
    [String[]]$UseSLA,
    # Manage Resource. Can contain any manageable ID.
    [String[]]$ManageResource,
    # Manage SLA. Must be an SLA ID.
    [String[]]$ManageSLA,
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
    # If User ID was not specified, get the current user ID
    if([string]::IsNullOrEmpty($id)) { 
        $id = (Get-RubrikUser -id me).id
        Write-Verbose "Using User ID $($id) as principal. This will infer the Organization ID automatically."
    } elseif ([string]::IsNullOrEmpty($PSBoundParameters.OrgID)) {
    # Unless specified and not using an inferred Org ID, API expects principal (ID) and Org ID to be the same
      $OrgID = $id
    }

    # Throw error on Global Org
    if((Get-RubrikOrganization -id $id).isGlobal) { throw "Operation not supported on Global Organization" }

    # Throw error if UseSLA, ManageResource and ManageSLA are all empty
    if([string]::IsNullOrEmpty($UseSLA) -and [string]::IsNullOrEmpty($ManageResource) -and [string]::IsNullOrEmpty($ManageSLA)) {
        throw "At least one of the parameters -UseSLA, -ManageResource, or -ManageSLA must be supplied"
    }

    # Build REST Body
    if($UseSLA.Length -gt 0) { $resources.Body.privileges.useSla.AddRange($UseSLA) }
    if($ManageResource.Length -gt 0) { $resources.Body.privileges.ManageResource.AddRange($ManageResource) }
    if($ManageSLA.Length -gt 0) { $resources.Body.privileges.ManageSLA.AddRange($ManageSLA) }
    $resources.Body.principals.Add($id) | Out-Null
    $resources.Body.organizationId = $OrgID
    $body = ConvertTo-Json -InputObject $resources.Body
    Write-Verbose -Message "Body = $body"    
    #endregion
    
    $uri = New-URIString -server $Server -endpoint ($resources.URI)
    $uri = Test-QueryParam -querykeys ($resources.Query.Keys) -parameters ((Get-Command $function).Parameters.Values) -uri $uri
    #$body = New-BodyString -bodykeys ($resources.Body.Keys) -parameters ((Get-Command $function).Parameters.Values)
    $result = Submit-Request -uri $uri -header $Header -method $($resources.Method) -body $body
    $result = Test-ReturnFormat -api $api -result $result -location $resources.Result
    $result = Test-FilterObject -filter ($resources.Filter) -result $result
    $result = Set-ObjectTypeName -TypeName $resources.ObjectTName -result $result

    return $result

  } # End of process
} # End of function