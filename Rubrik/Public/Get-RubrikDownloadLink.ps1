#requires -Version 3
function Get-RubrikDownloadLink
{
  <#  
      .SYNOPSIS
      Download a file from the Rubrik cluster

      .DESCRIPTION
      The Get-RubrikDownloadLink cmdlet is downlaod files from the Rubrik cluster

      .NOTES
      Written by Jaap Brasser for community usage
      Twitter: @jaap_brasser
      GitHub: jaapbrasser
      
      .LINK
      https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/get-rubrikdownloadlink

      .EXAMPLE
      something something download
  #>

  [CmdletBinding()]
  Param(
    # The name of the report
    [Parameter(Mandatory = $true)]
    [String]$Name,
    # The template this report is based on
    [Parameter(Mandatory = $true)]    
    [ValidateSet('ProtectionTasksDetails','ProtectionTasksSummary','SystemCapacity','SlaComplianceSummary')]
    [String]$ReportTemplate,
    # Rubrik server IP or FQDN
    [String]$Server = $global:RubrikConnection.server,
    # API version
    [String]$api = $global:RubrikConnection.api
  )

  Begin {
    
  }

  Process {

    $uri = New-URIString -server $Server -endpoint ($resources.URI) -id $id
    $uri = Test-QueryParam -querykeys ($resources.Query.Keys) -parameters ((Get-Command $function).Parameters.Values) -uri $uri
    $body = New-BodyString -bodykeys ($resources.Body.Keys) -parameters ((Get-Command $function).Parameters.Values)
    $result = Submit-Request -uri $uri -header $Header -method $($resources.Method) -body $body
    $result = Test-ReturnFormat -api $api -result $result -location $resources.Result
    Write-Verbose -Message "Download file 'abc' from 'uri'"

    return $result

  } # End of process
} # End of function