#requires -Version 3
function Export-RubrikVCDTemplate
{
  <#  
      .SYNOPSIS
      Exports a given vCD template

      .DESCRIPTION
      The Export-RubrikVCDTemplate cmdlet exports the specified vCD template

      .NOTES
      Written by Matt Elliott for community usage
      Twitter: @NetworkBrouhaha
      GitHub: shamsway

      .LINK
      https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/export-rubrikvcdtemplate

      .EXAMPLE
      Export-RubrikVCDTemplate -id '01234567-8910-1abc-d435-0abc1234d567' -Name 'Template-Export' -catalogid '01234567-8910-1abc-d435-0abc1234d567' -orgvdcid '01234567-8910-1abc-d435-0abc1234d567'
      This exports the vCD Template snapshot with ID 01234567-8910-1abc-d435-0abc1234d567 to the vCD catalog with ID 01234567-8910-1abc-d435-0abc1234d567. 
      The template will be exported to Org vDC ID with 01234567-8910-1abc-d435-0abc1234d567 temporarily, before being imported to the vCD catalog. This should be an Org vDC in the same vCD Org where the target catalog exists.
      Finding needed IDs can be done directly via API, or via a command similar to (Invoke-RubrikRESTCall -Endpoint 'vcd/hierarchy/VcdOrg:::01234567-8910-1abc-d435-0abc1234d567/children' -api 'internal' -Method GET).data
  #>

  [CmdletBinding()]
  Param(
    # Rubrik snapshot id of the vApp to export
    [Parameter(ValueFromPipelineByPropertyName = $true)]
    [ValidateNotNullOrEmpty()]
    [String]$id,
    # Name of the newly exported vCD Template. Defaults to [TemplateName]-Export
    [String]$name,
    # ID of target catalog. Defaults to the existing catalog.
    [Alias('catalog_id')]
    [String]$catalogid,
    # Org vDC ID to export the vCD Template to. This should be an Org vDC in the same vCD Org where the target catalog exists.
    [Alias('org_vdc_id')]
    [String]$orgvdcid,
    # ID of the storage policy used to create the template. Defaults to Org VDC settings.
    [String]$storagePolicyId,    
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

    if((!$name -or !$orgvdcid) -or !$catalogid) {
        $snapshot = Get-RubrikVAppSnapshot -id $id
        $vapp = Get-RubrikVApp -Name $snapshot.vappName -PrimaryClusterID 'local' -DetailedObject
        
        if(!$catalogid) {
            $catalogid = $vapp.catalogid
            Write-Verbose -Message "Using Catalog $($catalogid) for export"
        }
        if(!$name) {
            $name = $vapp.name + "-Export"
            Write-Verbose -Message "Using $($name) for export"
        }
        if(!$orgvdcid) {
            $options = Get-RubrikVcdTemplateExportOption -id $id -catalogid $catalogid -name $name
            $orgvdcid = $options.originalVdcExportOptions.orgVdcId
            Write-Verbose -Message "Using Org VDC $($orgvdc) for export"
        }
    }

    # Remove beginning of catalog ID to adjust for API
    if($catalogid.StartsWith('VcdCatalog:::')) {
        $catalogid = $catalogid -replace 'VcdCatalog:::',''
        }
    
    # Remove beginning of Org VDC ID to adjust for API
    if($orgvdcid.StartsWith('VcdOrgVdc:::')) {
        $orgvdcid = $orgvdcid -replace 'VcdOrgVdc:::',''
    }

    $resources.Body.name = $name
    $resources.Body.catalogId = $catalogid
    $resources.Body.orgVdcId = $orgvdcid
    if($storagePolicyId) {
        $resources.Body.storagePolicyId = $storagePolicyId
    }
    else {
        $resources.Body.Remove('storagePolicyId')
    }

    $body = ConvertTo-Json -InputObject $resources.Body -Depth 4
    Write-Verbose -Message "vApp Export REST Request Body `n$($body)"
    #endregion

    $uri = New-URIString -server $Server -endpoint ($resources.URI) -id $id
    $uri = Test-QueryParam -querykeys ($resources.Query.Keys) -parameters ((Get-Command $function).Parameters.Values) -uri $uri
    #$body = New-BodyString -bodykeys ($resources.Body.Keys) -parameters ((Get-Command $function).Parameters.Values)    
    $result = Submit-Request -uri $uri -header $Header -method $($resources.Method) -body $body
    $result = Test-ReturnFormat -api $api -result $result -location $resources.Result
    $result = Test-FilterObject -filter ($resources.Filter) -result $result

    return $result

  } # End of process
} # End of function