#requires -Version 3
function Get-RubrikDownloadLink
{
  <#  
    .SYNOPSIS
    Create a download link based on a snapshot object and a source dirs path

    .DESCRIPTION
    The Get-RubrikDownloadLink cmdlet creates a download link based on snapshot object paired with a sourceDirs path

    .NOTES
    Written by Jaap Brasser for community usage
    Twitter: @jaap_brasser
    GitHub: jaapbrasser
    
    .LINK
    https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/get-rubrikdownloadlink

    .EXAMPLE
    Get-RubrikFileSet -HostName jaap.testhost.us | Get-RubrikSnapshot -Latest | Get-RubrikDownloadLink -Verbose

    Will create a download link for the complete set of data from the jaap.testhost.us hostname while displaying verbose information

    .EXAMPLE
    Get-RubrikFileSet -HostName jaap.testhost.us | Get-RubrikSnapshot -Latest | Get-RubrikDownloadLink -sourceDirs '\test'

    Will only create a download link for files and folders located in the root folder 'test' of the selected fileset
  #>

  [CmdletBinding()]
  Param(
    # The SLA Object that should be downloaded
    [Parameter(
      Position = 0,
      ValueFromPipeline,
      Mandatory      
    )]
    [PSCustomObject] $SLAObject,
    # Which folders and files should be included, defaults to all "/"
    [string[]] $sourceDirs = @('/'),
    # Rubrik server IP or FQDN
    [String]$Server = $global:RubrikConnection.server
  )

  Process {
    Test-RubrikConnection

    $SLAObject | ForEach-Object {
      Write-Verbose -Message 'Build the URI'
      $uri = 'https://{0}/api/internal/{1}/snapshot/{2}/download_files' -f $Server,$_.sourceObjectType.ToLower(),$_.id
      Write-Verbose -Message "URI = $uri"
      Write-Verbose -Message 'Build the body parameters'
      $body = [pscustomobject]@{
          sourceDirs = $sourceDirs
      } | ConvertTo-Json
      Write-Verbose -Message "Body = $body"
      
      $StartTime = (Get-Date).ToUniversalTime()
            
      $Request = Submit-Request -uri $uri -header $Header -method Post -body $body

      $result = 1
      do {
        # Don't sleep the first time
        if ($result -ne 1) {
          Write-Progress -Activity 'Waiting for download link to be available on Rubrik Cluster'
          Start-Sleep -Seconds 5
        }

        $result = Get-RubrikEvent -object_ids ($Request.links -replace '.*?File_(.*?)_.*','$1') -Limit 5 |
          Where-Object {($_.Date -ge $StartTime) -and ($_.eventInfo -match 'Download link for')} |
          Sort-Object -Property Date | Select-Object -Last 1
      } until ($result)

      # Build the download string
      $result = 'https://{0}/{1}' -f $Server,($result.eventInfo -replace '.*?"(download_dir.*?)".*','$1')
      
      return $result
    }
  } # End of process
} # End of function