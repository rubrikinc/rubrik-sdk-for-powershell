function Start-RubrikVMDownload
{
  <#  
    .SYNOPSIS
    Download a file from the Rubrik cluster from a specific snapshot

    .DESCRIPTION
    The Start-RubrikVMDownload cmdlet will download files from the Rubrik cluster, it can either take a uri or a snapshot object paired with a path (paths). Returns the file object
    Based on Start-RubrikDownload cmdlet created by Jaap Brasser and modified to VM snapshots


    .NOTES
    Written by Jaap Brasser for community usage
    Twitter: @jaap_brasser
    GitHub: jaapbrasser
    Modified by Mats Ekman for community usage
    Twitter: @MatsBEkman

    .LINK
    https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/start-rubrikvmdownload

    .EXAMPLE
     $GetRubrikVMSnapshot = Get-RubrikVMSnapshot -id <snapshotid>
     $StartRubrikVMDownload = $GetRubrikVMSnapshot | Start-RubrikVMDownload -Path <downloaded filename> -paths <filename>


    Will download the specified file from the Rubrik cluster from the specific snapshot

    .EXAMPLE
     $GetRubrikVM = Get-RubrikVM -Name <hostname>
     $FindRubrikFile = $GetRubrikVM | Find-RubrikFile -SearchString <tag file created for the backup>
     $GetRubrikVMSnapshot = Get-RubrikVMSnapshot -id $FindRubrikFile.fileVersions.snapshotId
     $StartRubrikVMDownload = $GetRubrikVMSnapshot | Start-RubrikVMDownload -Path <downloaded filename> -paths <filename>


    Will download the specified file from the Rubrik cluster to the <dowloaded filename>
    Important here is to make sure that $FindRubrikFile.fileVersions.snapshotId is not empty
  #>

  [CmdletBinding(DefaultParameterSetName = 'Uri')]
  Param(
    # The URI to download 
    [Parameter(
      ParameterSetName= 'uri',
      Position = 0,
      Mandatory
    )]
    [string] $Uri,
    # The SLA Object that should be downloaded
    [Parameter(
      ParameterSetName = "pipeline",
      Position = 0,
      ValueFromPipeline,
      Mandatory      
    )]
    [PSCustomObject] $SLAObject,
    # The path where the folder where the zip files should be downloaded to, if no file extension is specified the file will downloaded with default filename
    [Parameter(
      ParameterSetName = "pipeline",
      Position = 1
    )]
    [Parameter(
      ParameterSetName = "uri",
      Position = 1
    )]
    [string] $Path,
    # Which filename and path where the downloaded file(s) ends up
    [Parameter(
      ParameterSetName = "pipeline",
      Position = 1
    )]
    [Parameter(
      ParameterSetName = "uri",
      Position = 1
    )]
    [string[]] $paths = @('/')
    #Which file(s) should be included. You must be sure that this file exists
  )

  Process {
    if ($PSCmdlet.ParameterSetName -eq 'pipeline') {
      $LinkSplat = @{
        SlaObject = $SLAObject
        paths = $paths
      }
      $uri = Get-RubrikVMDownloadLink @LinkSplat
    }

    $WebRequestSplat = @{
      Uri = $Uri
    }

    if ($Path -match '\.' -and (-not (Get-Item -EA 0 -LiteralPath $Path|Where-Object psiscontainer -eq $true))) {
      $WebRequestSplat.OutFile = $Path
    } elseif ($Path) {
      $WebRequestSplat.OutFile = Join-Path $Path (Split-Path -Path $uri -Leaf)
    } else {
      $WebRequestSplat.OutFile = Split-Path -Path $uri -Leaf
    }

    if (Test-PowerShellSix) {
      $WebRequestSplat.SkipCertificateCheck = $true
      Invoke-WebRequest @WebRequestSplat
    } else {
      Invoke-WebRequest @WebRequestSplat
    }

    return Get-Item $WebRequestSplat.OutFile
  } # End of process
} # End of function
