#requires -Version 3
function Get-RubrikVCDTemplateExportOption
{
  <#  
      .SYNOPSIS
      Retrieves export options for a vCD Template known to a Rubrik cluster

      .DESCRIPTION
      The Get-RubrikVCDTemplateExportOption cmdlet retrieves export options for a vCD Template known to a Rubrik cluster

      .NOTES
      Written by Matt Elliott for community usage
      Twitter: @NetworkBrouhaha
      GitHub: shamsway

      .LINK
      https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/get-rubrikvcdtemplateexportoption

      .EXAMPLE
      $SnapshotID = (Get-RubrikVApp -Name 'vAppTemplate01' | Get-RubrikSnapshot -Latest).id
      Get-RubrikVCDTemplateExportOption -id $SnapshotID -catalogid 'VcdCatalog:::01234567-8910-1abc-d435-0abc1234d567' -Name 'vAppTemplate01-export'
      This will return export options details on the specific snapshot.
  #>

  [CmdletBinding()]
  Param(
    # Snapshot ID of the vCD Template to retrieve options for
    [Parameter(Mandatory = $true,ValueFromPipelineByPropertyName = $true)]
    [ValidateNotNullOrEmpty()]
    [Alias('snapshot_id')]
    [String]$id,
    # ID of target catalog. Defaults to the existing catalog.
    [Alias('catalog_id')]
    [String]$catalogid,
    # Name of the newly exported vCD Template. Defaults to [TemplateName]-Export
    [String]$name,
    # Org vDC ID to export the vCD Template to. This should be an Org vDC in the same vCD Org where the target catalog exists.
    [Alias('org_vdc_id')]
    [String]$orgvdcid,
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
    #region oneoff
    
    # Remove beginning of catalog ID to adjust for API
    if($catalogid.StartsWith('VcdCatalog:::')) {
      $catalogid = $catalogid -replace 'VcdCatalog:::',''
    }

    # Remove beginning of Org VDC ID to adjust for API
    if($orgvdcid.StartsWith('VcdOrgVdc:::')) {
      $orgvdcid = $orgvdcid -replace 'VcdOrgVdc:::',''
    }

    if(!$name) {
      $snapshot = Get-RubrikVAppSnapshot -id $id
      $vapp = Get-RubrikVApp -Name $snapshot.vappName -PrimaryClusterID 'local' -DetailedObject
      $name = $vapp.name + "-Export"
      Write-Verbose -Message "Using $($name) for export"
    }
    #endregion

    $uri = New-URIString -server $Server -endpoint ($resources.URI) -id $id
    $uri = Test-QueryParam -querykeys ($resources.Query.Keys) -parameters ((Get-Command $function).Parameters.Values) -uri $uri
    $body = New-BodyString -bodykeys ($resources.Body.Keys) -parameters ((Get-Command $function).Parameters.Values)    
    $result = Submit-Request -uri $uri -header $Header -method $($resources.Method) -body $body
    $result = Test-ReturnFormat -api $api -result $result -location $resources.Result
    $result = Test-FilterObject -filter ($resources.Filter) -result $result

    return $result

  } # End of process
} # End of function