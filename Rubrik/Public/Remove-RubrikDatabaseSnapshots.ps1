#requires -Version 3
function Remove-RubrikDatabaseSnapshots
{
  <#
      .SYNOPSIS
      Connects to Rubrik and removes all database snapshots for a given database.

      .DESCRIPTION
      The Remove-RubrikFilesetSnapshot cmdlet will request that the Rubrik API delete all snapshots for a given rubrik database.
      The database must be unprotected for this operation to succeed.

      .NOTES
      Written by Mike Preston for community usage
      Twitter: @mwpreston
      GitHub: mwpreston

      .LINK
      https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/remove-rubrikdatabasesnapshots

      .EXAMPLE
      Remove-RubrikDatabaseSnapshots -id '01234567-8910-1abc-d435-0abc1234d567'
      This will attempt to remove all database snapshots for the database with an id of `01234567-8910-1abc-d435-0abc1234d567`

      .EXAMPLE
      Remove-RubrikDatabaseSnapshots -id '01234567-8910-1abc-d435-0abc1234d567' -Confirm:$false
      This will attempt to remove all database snapshots for the database with an id of `01234567-8910-1abc-d435-0abc1234d567` without user confirmation

      .EXAMPLE
      Get-RubrikDatabase -id '1111-2222-3333' |  Remove-RubrikDatabaseSnapshots
      This will attempt to remove all database snapshots for the database with an id of '1111-2222-3333'
  #>

  [CmdletBinding(SupportsShouldProcess = $true,ConfirmImpact = 'High')]
  Param(
    # Database ID of the database to delete snapshots from
    [Parameter(Mandatory = $true,ValueFromPipelineByPropertyName = $true)]
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
    if ($PSCmdlet.ShouldProcess("$id", "Remove all snapshots ")) {
        $uri = New-URIString -server $Server -endpoint ($resources.URI) -id $id
        $uri = Test-QueryParam -querykeys ($resources.Query.Keys) -parameters ((Get-Command $function).Parameters.Values) -uri $uri
        $body = New-BodyString -bodykeys ($resources.Body.Keys) -parameters ((Get-Command $function).Parameters.Values)
        $result = Submit-Request -uri $uri -header $Header -method $($resources.Method) -body $body
        $result = Test-ReturnFormat -api $api -result $result -location $resources.Result
        $result = Test-FilterObject -filter ($resources.Filter) -result $result

        return $result
    }
  } # End of process
} # End of function