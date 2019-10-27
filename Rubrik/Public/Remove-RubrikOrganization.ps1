#requires -Version 3
function Remove-RubrikOrganization
{
  <#  
      .SYNOPSIS
      Remove an organization from a Rubrik cluster.

      .DESCRIPTION
      The Remove-RubrikOrganization cmdlet is used to remove an existing orgazniation from a Rubrik cluster.

      .NOTES
      Written by Matt Elliott for community usage
      Twitter: @NetworkBrouhaha
      GitHub: shamsway

      .LINK
      https://rubrik.gitbook.io/rubrik-sdk-for-powershell/

      .EXAMPLE
      Get-RubrikOrganization -Name "MyOrg" | Remove-RubrikOrganization
      This will remove the organization named "MyOrg"

      .EXAMPLE
      Remove-RubrikOrganization -ID 'Organization:::01234567-8910-1abc-d435-0abc1234d567'
      This will remove the organization with ID "Organization:::01234567-8910-1abc-d435-0abc1234d567"
  #>

  [CmdletBinding(SupportsShouldProcess = $true,ConfirmImpact = 'High')]
  Param(
    # ID of the organization to remove
    [Parameter(Mandatory = $true,ValueFromPipelineByPropertyName = $true)]
    [ValidateNotNullOrEmpty()]
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