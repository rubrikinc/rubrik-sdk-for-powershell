#requires -Version 3
function Start-RubrikDownload
{
  <#  
      .SYNOPSIS
      Download a file from the Rubrik cluster

      .DESCRIPTION
      The Start-RubrikDownload cmdlet is downlaod files from the Rubrik cluster

      .NOTES
      Written by Jaap Brasser for community usage
      Twitter: @jaap_brasser
      GitHub: jaapbrasser
      
      .LINK
      https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/start-rubrikdownload

      .EXAMPLE
      Start-RubrikDownload -Uri https://cluster-b.rubrik.us/download_dir/EVep2PMDpJEAWhIQS6Si.zip
  #>

  [CmdletBinding(DefaultParameterSetName = 'Uri')]
  Param(
    # The URI to download 
    [Parameter(
      ParameterSetName= 'uri',
      Position = 0,
      Mandatory = $true
    )]
    [string] $Uri,
    # Filter all the events by object type. Enter any of the following values
    [ValidateSet('VmwareVm', 'Mssql', 'Fileset', 'WindowsHost', 'LinuxHost', 'StorageArrayVolumeGroup', 'VolumeGroup', 'NutanixVm', 'Oracle')]
    [Parameter(
      ParameterSetName = "Object",
      Position = 1
    )]
    [string]$ObjectType,

    # Rubrik server IP or FQDN
    [String]$Server = $global:RubrikConnection.server,
    # API version
    [String]$api = $global:RubrikConnection.api
  )

  Begin {
    
  }

  Process {
    if ($uri) {
      if (Test-PowerShellSix) {
        Invoke-WebRequest -Uri $Uri -SkipCertificateCheck -OutFile (Split-Path -Path $uri -Leaf)
      } else {
        Invoke-WebRequest -Uri $Uri -OutFile (Split-Path -Path $uri -Leaf)
      }
    }

    $TimeStamp = Get-Date
    $SnapshotID = (Get-RubrikFileSet -HostName AFS.Rubrik.us -Verbose | Get-RubrikSnapshot -Latest).id
    $DLLink = Invoke-RubrikRESTCall -Method Post -api internal -Endpoint "fileset/snapshot/$SnapshotID/download_files" -Body ([pscustomobject]@{sourceDirs=@("/")}) -verbose
    Get-RubrikEvent -object_ids ($DLLink.links -replace '.*?File_(.*?)_.*','$1') -Limit 1 -AfterDate $TimeStamp


    $uri = New-URIString -server $Server -endpoint ($resources.URI) -id $id
    $uri = Test-QueryParam -querykeys ($resources.Query.Keys) -parameters ((Get-Command $function).Parameters.Values) -uri $uri
    $body = New-BodyString -bodykeys ($resources.Body.Keys) -parameters ((Get-Command $function).Parameters.Values)
    $result = Submit-Request -uri $uri -header $Header -method $($resources.Method) -body $body
    $result = Test-ReturnFormat -api $api -result $result -location $resources.Result
    Write-Verbose -Message "Download file 'abc' from 'uri'"

    return $result

  } # End of process
} # End of function