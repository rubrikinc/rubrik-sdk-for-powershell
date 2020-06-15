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
      https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/set-rubriknasshare

      .EXAMPLE
      Get-RubrikNASShare -name 'FOO' | Set-RubrikNASShare -ExportPoint 'TEMP' 

      Update the NAS Share FOO with the export point of TEMP.

      .EXAMPLE
      Get-RubrikNASShare -name 'FOO' | Set-RubrikNASShare -Credential (Get-Credential)

      Update the NAS Share FOO with the credentials specified
  #>

  [cmdletbinding(SupportsShouldProcess=$true,DefaultParametersetName='Credential')]
  Param(
    # NAS Share ID
    [Parameter(Mandatory = $true,ValueFromPipelineByPropertyName = $true)]    
    [String]$Id,
    # New export point for the share
    [Parameter(ParameterSetName='Credential',Mandatory=$true, Position = 1)]
    [System.Management.Automation.CredentialAttribute()]$Credential,
    # Username to assign to NAS Share
    [Parameter(ParameterSetName='UserPassword',Mandatory=$true, Position = 1)]
    [String]$Username,
    # Password for the Username provided
    [Parameter(ParameterSetName='UserPassword',Mandatory=$true, Position = 2)]
    [SecureString]$Password,
    # Domain for the user
    [Parameter(ParameterSetName='UserPassword',Mandatory=$false, Position = 3)]
    [SecureString]$Domain,
    # Rubrik server IP or FQDN
    [String]$ExportPoint,
    # New NAS Share credential
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

    #region one-off
    #Convert credential to valid body values
    $body = @{}

    # Block if credential was specified
    if ($Credential) {
      $body.username = $Credential.GetNetworkCredential().UserName
      $body.password = $Credential.GetNetworkCredential().Password
      if ($Credential.GetNetworkCredential().Domain) {
        $body.domain = $Credential.GetNetworkCredential().Domain
      }
    } 
    
    # Block for username/password combination
    if ($UserName) {
      $body.username = $UserName
    }
    if ($Password) {
      $body.password = (New-Object PSCredential "user",$Password).GetNetworkCredential().Password
    }
    if ($Domain) {
      $body.domain = $Domain
    } 
    
    if ($ExportPoint) {
      $body.exportPoint = $ExportPoint
    }

    $body = ConvertTo-Json $body
    Write-Verbose "Body = $($body|out-string)"
    #endregion

    $result = Submit-Request -uri $uri -header $Header -method $($resources.Method) -body $body
    $result = Test-ReturnFormat -api $api -result $result -location $resources.Result
    $result = Test-FilterObject -filter ($resources.Filter) -result $result
    $result = Set-ObjectTypeName -TypeName $resources.ObjectTName -result $result

    return $result

  } # End of process
} # End of function