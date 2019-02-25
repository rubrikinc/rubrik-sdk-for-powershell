#requires -Version 3
function Set-RubrikNASShare
{
  <#  
      .SYNOPSIS
      Change settings for a NAS share

      .DESCRIPTION
      Update NAS share settings that are configured in Rubrik, such as updating the export point or
      change the NAS credentials

      .NOTES
      Written by Mike Fal
      Twitter: @Mike_Fal
      GitHub: MikeFal
      Any other links you'd like here

      .LINK
      https://github.com/rubrikinc/rubrik-sdk-for-powershell

      .EXAMPLE
      Get-RubrikNASShare -name 'FOO' | Set-RubrikNASShare -ExportPoint 'TEMP' 

      Update the NAS Share FOO with the export point of TEMP.
  #>

  [CmdletBinding()]
  Param(
    # NAS Share ID
    [Parameter(Mandatory = $true,ValueFromPipelineByPropertyName = $true)]    
    [String]$Id,
    # New export point for the share
    [String]$ExportPoint,
    # New NAS Share credential
    [pscredential]$Credential,    
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

    #region one-off
    #Convert credential to valid body values
    $bodytemp = ConvertFrom-Json $body
    $bodytemp.Add('username',$Credential.GetNetworkCredential().UserName)
    $bodytemp.Add('password',$Credential.GetNetworkCredential().Password)
    $bodytemp.Add('domain',$Credential.GetNetworkCredential().Domain)
    $body = ConvertTo-Json $bodytemp
    #endregion

    $result = Submit-Request -uri $uri -header $Header -method $($resources.Method) -body $body
    $result = Test-ReturnFormat -api $api -result $result -location $resources.Result
    $result = Test-FilterObject -filter ($resources.Filter) -result $result

    return $result

  } # End of process
} # End of function