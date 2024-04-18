#requires -Version 3
function Get-RubrikVMDownloadLink
{
  <#  
    .SYNOPSIS
    Create a download link based on a snapshot object and a path (paths)

    .DESCRIPTION
    The Get-RubrikVMDownloadLink cmdlet creates a download link based on snapshot object paired with a path (paths)
    Based on Get-RubrikDownloadLink cmdlet created by Jaap Brasser and modified to VM snapshots

    .NOTES
    Written by Jaap Brasser for community usage
    Twitter: @jaap_brasser
    GitHub: jaapbrasser
    Modified by Mats Ekman for community usage
    Twitter: @MatsBEkman

    .LINK
    https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/get-rubrikvmdownloadlink

    .EXAMPLE
     $Snapshot = Get-RubrikVMSnapshot -id <snapshotid>
     $DownloadLink = $Snapshot | Get-RubrikVMDownloadLink -paths "C:\path\to\file"

    Will create a download link for the file specified

    .EXAMPLE
     $vm = Get-RubrikVM -Name <hostname>
     $rubrikFile = $vm | Find-RubrikFile -SearchString <tag file created for the backup>
     $snapshot = Get-RubrikVMSnapshot -id $rubrikFile.fileVersions.snapshotId
     $DownloadLink = $snapshot | Get-RubrikVMDownloadLink -paths "C:\path\to\file"

    Will only create a download link for the file specified in the snapshot specified
    Important here is to make sure that $rubrikFile.fileVersions.snapshotId is not empty
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
    # Which file(s) should be included. You must be sure that this file exists
    [string[]] $paths = @('/'),
    # Rubrik server IP or FQDN
    [String]$Server = $global:RubrikConnection.server
  )

  Process {
    Test-RubrikConnection

    $SLAObject | ForEach-Object {
      Write-Verbose -Message 'Build the URI'
      $uri = 'https://{0}/api/internal/vmware/vm/snapshot/{1}/download_files' -f $Server,$_.id
      Write-Verbose -Message "URI = $uri"
      Write-Verbose -Message 'Build the body parameters'
      $body = [pscustomobject]@{
          paths = $paths
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
          Where-Object {(([DateTime]$_.time).ToUniversalTime() -ge $StartTime) -and ($_.eventInfo -match 'Download link for')} |
          Sort-Object -Property Date | Select-Object -Last 1
      } until ($result)

      # Build the download string
      $result = 'https://{0}/{1}' -f $Server,($result.eventInfo -replace '.*?"(download_dir.*?)".*','$1')
      
      return $result
    }
  } # End of process
} # End of function
