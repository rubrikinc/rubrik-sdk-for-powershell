#Requires -Version 3
function New-RubrikManagedVolumeExport
{
  <#
      .SYNOPSIS
      Creates an export of a Managed Volume snapshot

      .DESCRIPTION
      The New-RubrikManagedVolumeExport command will request the creation of
      a Managed Volume export of the specified Managed Volume snapshot

      .NOTES
      Written by Mike Fal
      Twitter: @Mike_Fal
      GitHub: MikeFal

      .LINK
      https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/new-rubrikmanagedvolumeexport

      .EXAMPLE
      Get-RubrikSnapshot -id ManagedVolume:::f68ecd45-bdb9-46dd-aea4-8f041fb2dec2 | Select-Object -First 1 | New-RubrikManagedVolumeExport

      Create an export (live mount) of the most recent snapshot for the specified managed volume.
  #>

  [CmdletBinding(SupportsShouldProcess = $true,ConfirmImpact = 'High')]
  Param(
    # Rubrik identifier of Managed Volume snapshot to be exported
    [Parameter(Mandatory = $true,ValueFromPipelineByPropertyName = $true)]
    [String]$Id,
    #Source Managed Volume Name
    [String]$SourceManagedVolumeName,
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

    $uri = New-URIString -server $Server -endpoint ($resources.URI) -id $Id
    $uri = Test-QueryParam -querykeys ($resources.Query.Keys) -parameters ((Get-Command $function).Parameters.Values) -uri $uri

    #region One-off
    #API call uses only GUID for ID, not ManagedVolume:::+GUID
    $uri = $uri.Replace('ManagedVolume:::','')
    #Force all hostPatterns for JSON payload
    $body = '{"hostPatterns":["*"]}'
    #endregion
    $result = Submit-Request -uri $uri -header $Header -method $($resources.Method) -body $body
    $result = Test-ReturnFormat -api $api -result $result -location $resources.Result
    $result = Test-FilterObject -filter ($resources.Filter) -result $result

    return $result

  } # End of process
} # End of function