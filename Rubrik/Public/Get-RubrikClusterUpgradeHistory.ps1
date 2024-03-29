#Requires -Version 3
function Get-RubrikClusterUpgradeHistory
{
  <#
    .SYNOPSIS
    Retrieves upgrade history for a given cluster

    .DESCRIPTION
    The Get-RubrikClusterUpgradeHistory cmdlet will retrieve upgrade history for a given cluster.

    .NOTES
    Written by Jaap Brasser for community usage
    Twitter: @jaap_brasser
    GitHub: jaapbrasser

    .LINK
    https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/get-rubrikclusterupgradehistory

    .EXAMPLE
    Get-RubrikClusterUpgradeHistory
    
    This will return the upgrade history for the currently authenticated cluster.

    .EXAMPLE
    Get-RubrikClusterUpgradeHistory -Verbose
    
    This will return the upgrade history for the currently authenticated cluster, while displaying verbose information
  #>

  [CmdletBinding()]
  Param(
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
    
    # Specific filtering for Upgrade History, fixes broken JSON metadata and filters to one object per upgrade
    $result | ForEach-Object {
      [pscustomobject]@{
        Version = ($_.configChangeMetadata | ConvertFrom-Json).tarball_version
        DateTime = $_.modifiedDateTime
        Source = $_.source
      }
    } | Group-Object -Property version | ForEach-Object {
      $_.group[0]
    }

    #return $result

  } # End of process
} # End of function