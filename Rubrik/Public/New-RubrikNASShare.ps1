#requires -Version 3
function New-RubrikNASShare
{
  <#  
      .SYNOPSIS
      Creates a new NAS share in Rubrik for backup operations

      .DESCRIPTION
      Registers a new NAS share in Rubrik. Once created, this NAS share can be associated with
      filesets for appropriate fileset backups. Note, a host must first be created using
      New-RubrikHost for the NAS share to be associated.

      .NOTES
      Written by Mike Fal
      Twitter: @Mike_Fal
      GitHub: MikeFal
      
      .LINK
      https://github.com/rubrikinc/rubrik-sdk-for-powershell

      .EXAMPLE
      New-RubrikNASShare -HostID (Get-RubrikHost 'FOO').id -ShareType NFS -ExportPoint BAR -Credential (Get-Credential)

      Create a new NFS share for host FOO, export point BAR.
  #>

  [CmdletBinding(SupportsShouldProcess = $true,ConfirmImpact = 'High')]
  Param(
    #Host ID that the NAS share will be associated with
    [Parameter(Mandatory = $true)]
    [String]$HostID,
    #Share type - NFS or SMB
    [Parameter(Mandatory = $true)]
    [ValidateSet('NFS','SMB')]
    [String]$ShareType,
    #Export point - Share Name
    [String]$ExportPoint,
    #Credential for NAS share
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
    if($Credential){
      $bodytemp = ConvertFrom-Json $body
      $bodytemp | Add-Member -MemberType NoteProperty -Name 'username' -Value $Credential.GetNetworkCredential().UserName
      $bodytemp | Add-Member -MemberType NoteProperty -Name 'password' -Value $Credential.GetNetworkCredential().Password 
      $bodytemp | Add-Member -MemberType NoteProperty -Name 'domain' -Value $Credential.GetNetworkCredential().Domain 
      $body = ConvertTo-Json $bodytemp
    }
    #endregion

    $result = Submit-Request -uri $uri -header $Header -method $($resources.Method) -body $body
    $result = Test-ReturnFormat -api $api -result $result -location $resources.Result
    $result = Test-FilterObject -filter ($resources.Filter) -result $result

    return $result

  } # End of process
} # End of function