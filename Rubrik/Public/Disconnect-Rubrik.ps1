#requires -Version 3
function Disconnect-Rubrik
{
  <#  
      .SYNOPSIS
      Disconnects from a Rubrik cluster

      .DESCRIPTION
      The Disconnect-Rubrik function is used to disconnect from a Rubrik cluster.
      This is done by supplying the bearer token and requesting that the session be deleted.

      .NOTES
      Written by Chris Wahl for community usage
      Twitter: @ChrisWahl
      GitHub: chriswahl

      .LINK
      http://rubrikinc.github.io/rubrik-sdk-for-powershell/reference/Disconnect-Rubrik.html

      .EXAMPLE
      Disconnect-Rubrik -Confirm:$false
      This will close the current session and invalidate the current session token without prompting for confirmation

      .EXAMPLE
      $rubrikConnection = $RubrikConnections[1]
      Disconnect-Rubrik
      This will close the second session and invalidate the second session token
      Note: The $rubrikConnections variable holds session details on all established sessions
            The $rubrikConnection variable holds the current, active session
            If you wish to change sessions, simply update the value of $rubrikConnection to another session held within $rubrikConnections
  #>

  [CmdletBinding(SupportsShouldProcess = $true,ConfirmImpact = 'High')]
  Param(
    # Session id
    [Parameter(ValueFromPipelineByPropertyName = $true)]    
    [String]$id = 'me',    
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
    
    if ($global:RubrikConnection.authType -eq 'Token') {
      Write-Verbose -Message "Detected token authentication - Disconnecting without deleting token."
      $global:RubrikConnection = $null
      $result = $null
    }
    else {
      $uri = New-URIString -server $Server -endpoint ($resources.URI) -id $id
      $uri = Test-QueryParam -querykeys ($resources.Query.Keys) -parameters ((Get-Command $function).Parameters.Values) -uri $uri
      $body = New-BodyString -bodykeys ($resources.Body.Keys) -parameters ((Get-Command $function).Parameters.Values)
      $result = Submit-Request -uri $uri -header $Header -method $($resources.Method) -body $body
      $result = Test-ReturnFormat -api $api -result $result -location $resources.Result
      $result = Test-FilterObject -filter ($resources.Filter) -result $result
    }

    return $result

  } # End of process
} # End of function