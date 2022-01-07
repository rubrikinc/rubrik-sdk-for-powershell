#requires -Version 3
function Get-RubrikDatabaseDownloadLink
{
  <#  
    .SYNOPSIS
    Create a download link to retrieve SQL Database files from snapshot

    .DESCRIPTION
    The Get-RubrikDatabaseDownloadLink cmdlet creates a download link containing the SQL database files (mdf/ldf) of a given snapshot

    .NOTES
    Written by Mike Preston for community usage
    Twitter: @mwpreston
    GitHub: mwpreston
    
    .LINK
    https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/get-rubrikdatabasedownloadlink

    .EXAMPLE
    $db = Get-RubrikDatabase AdventureWorks
    $snapshot = $db | Get-RubrikSnapshot -Date '01/01/22'
    $url = Get-RubrikDatabaseDownloadLink -id $db.id -SnapshotId $snapshot.id

    Will create a download link for the mdf/ldf files contained within the AdventureWorks database snapshot closest to January 1, 2021

    .EXAMPLE
    $db = Get-RubrikDatabase AdventureWorks
    $url = Get-RubrikDatabaseDownloadLink -id $db.id -SnapshotId "Latest"

    Will create a download link for the mdf/ldf files contained within the latest AdventureWorks database snapshot
  #>

  [CmdletBinding()]
  Param(
    # SQL Database ID
    [Alias('DatabaseId')]
    [Parameter(
      Mandatory = $true     
    )]
    [String] $id,
    # Snapshot ID
    [Parameter(
        Mandatory = $true
    )]
    [string] $SnapshotId,
    # Rubrik server IP or FQDN
    [String]$Server = $global:RubrikConnection.server
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
    Write-Verbose -Message "Load API data for $($resources.URI)"
    Write-Verbose -Message "Description: $($resources.Description)"

  }

  Process {


    $uri = New-URIString -server $Server -endpoint ($resources.URI) -id $id
    $uri = Test-QueryParam -querykeys ($resources.Query.Keys) -parameters ((Get-Command $function).Parameters.Values) -uri $uri

    if ($SnapshotId.ToUpper() -eq "LATEST") {
        $SnapshotId = (Get-RubrikDatabase -id $id | Get-RubrikSnapshot -Latest).id
    }
    $body = @"
    {
        "items": ["$SnapshotId"]
    }
"@


    Write-Verbose -Message "Body is $body"

    $Request = Submit-Request -uri $uri -header $Header -method $($resources.Method) -body $body
    $result = 1
    do {
      # Don't sleep the first time
      if ($result -ne 1) {
        Write-Progress -Activity 'Waiting for download link to be available on Rubrik Cluster'
        Start-Sleep -Seconds 5
      }

      $result = Get-RubrikEvent -object_ids $id -Limit 15 |
        Where-Object {(([DateTime]$_.time).ToUniversalTime() -ge $request.StartTime) -and ($_.eventInfo -match 'Download link for')} |
        Sort-Object -Property Date | Select-Object -Last 1
    } until ($result)

    # Build the download string
    $result = 'https://{0}/{1}' -f $Server,($result.eventInfo -replace '.*?"(download_dir.*?)".*','$1')

    return $result
  
  } # End of process
} # End of function
