function Start-RubrikDownload
{
  <#  
    .SYNOPSIS
    Download a file from the Rubrik cluster

    .DESCRIPTION
    The Start-RubrikDownload cmdlet will download files from the Rubrik cluster, it can either take a uri or a snapshot object paired with a sourceDirs path. Returns the file object

    .NOTES
    Written by Jaap Brasser for community usage
    Twitter: @jaap_brasser
    GitHub: jaapbrasser
    
    .LINK
    https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/start-rubrikdownload

    .EXAMPLE
    Start-RubrikDownload -Uri https://cluster-b.rubrik.us/download_dir/EVep2PMDpJEAWhIQS6Si.zip

    Will download the specified file from the Rubrik cluster to the current folder

    .EXAMPLE
    Start-RubrikDownload -Uri https://cluster-b.rubrik.us/download_dir/EVep2PMDpJEAWhIQS6Si.zip -Path /Temp

    Will download the specified file from the Rubrik cluster to the 'Temp' folder

    .EXAMPLE
    Start-RubrikDownload -Uri https://cluster-b.rubrik.us/download_dir/EVep2PMDpJEAWhIQS6Si.zip -Path "/Temp/MyImportedFileSet.zip"

    Will download the specified file from the Rubrik cluster to the 'Temp' folder with the 'MyImportedFileSet.zip' filename

    .EXAMPLE
    Get-RubrikFileSet -HostName jaap.testhost.us | Get-RubrikSnapshot -Latest | Start-RubrikDownload -Verbose

    Will download the complete set of data from the jaap.testhost.us hostname while displaying verbose information

    .EXAMPLE
    Get-RubrikFileSet -HostName jaap.testhost.us | Get-RubrikSnapshot -Latest | Start-RubrikDownload -sourceDirs '\test'

    Will only download files and folders located in the root folder 'test' of the selected fileset
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
    # Which folders and files should be included, defaults to all "/"
    [Parameter(
      ParameterSetName = "pipeline",
      Position = 1
    )]
    [Parameter(
      ParameterSetName = "uri",
      Position = 1
    )]
    [string[]] $sourceDirs = @('/')
  )

  Process {
    if ($PSCmdlet.ParameterSetName -eq 'pipeline') {
      $LinkSplat = @{
        SlaObject = $SLAObject
        sourceDirs = $sourceDirs
      }
      $uri = Get-RubrikDownloadLink @LinkSplat
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