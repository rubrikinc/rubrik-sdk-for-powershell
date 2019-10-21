#Requires -Version 3
function Get-RubrikClusterStorage
{
  <#  
      .SYNOPSIS
      Connects to Rubrik and retrieves node information for a given cluster
            
      .DESCRIPTION
      The Get-RubrikClusterStorage cmdlet will retrieve various capacity and usage information about cluster storage.
            
      .NOTES
      Written by Mike Preston for community usage
      Twitter: @mwpreston
      GitHub: mwpreston
            
      .LINK
      http://rubrikinc.github.io/rubrik-sdk-for-powershell/reference/Get-RubrikClusterStorage.html
            
      .EXAMPLE
      Get-RubrikClusterStorage
      This will return the storage capacity and usage information about the authenticated cluster.
  #>

  [CmdletBinding()]
  Param(
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
    $precision = 1
    $tb = 1000000000000
    $gb = 1000000000
    $result = @{}
    foreach ($key in $resources.URI.Keys ) {
        $uri = New-URIString -server $Server -endpoint $Resources.URI[$key] -id $id
        $iresult = Submit-Request -uri $uri -header $Header -method $($resources.Method) -body $body
        switch ($key) {
            {$_ -in "DiskCapacityInTb","FlashCapacityInTb"} { $result.Add($key, ([Math]::round(($iresult.bytes/$tb),$precision))) }
            "StorageOverview" {
                $result.add("TotalUsableStorageInTb",([Math]::round(($iresult.total/$tb),$precision)))
                $result.add("UsedStorageInTb",([Math]::round(($iresult.used/$tb),$precision)))
                $result.add("AvailableStorageInTb",([Math]::round(($iresult.available/$tb),$precision)))
                $result.add("SnapshotStorageInTb",([Math]::round(($iresult.snapshot/$tb),$precision)))
                $result.add("LiveMountStorageInGb",([Math]::round(($iresult.livemount/$gb),$precision)))
                $result.add("MiscellaneousStorageInGb",([Math]::round(($iresult.miscellaneous/$gb),$precision)))
                $SnapshotStorageInBy = $iresult.snapshot # For later usage
                $AvailableStorageInBy = $iresult.available # for later calculations
            }
            "CloudStorage" {  
              $result.add("ArchivalUsageInTb", ([Math]::round(($iresult.value/$tb),$precision))) 
              $ArchivalUsageInBy = $iresult.value # for later usage
            }
            "DailyGrowth" { 
              $result.add("AverageGrowthPerDayInGb", ([Math]::round(($iresult.bytes/$gb),$precision))) 
              $DailyGrowthInBy = $iresult.bytes # for later calculations
            }
            "CloudStorageIngested" { 
              $result.add("TotalArchiveStorageIngestedInTb",([Math]::round(($iresult.value/$tb),$precision)))
              $IngestedArchiveStorageInB = $iresult.value
            } 
            "LocalStorageIngested" { 
              $result.add("TotalLocalStorageIngestedInTb",([Math]::round(($iresult.value/$tb),$precision)))
              $IngestedLocalStorageInB = $iresult.value
            } 
        }
    }
    
    # Calculate data reduction numbers with ingested storage, and estimated runway,add to results
    $ArchivalDataReduction = [Math]::round(100 - (($ArchivalUsageInBy/$IngestedArchiveStorageInB) * 100),1)
    $result.Add("ArchivalDataReductionPercent",$ArchivalDataReduction)
    $LocalDataReduction = [Math]::round(100-(($SnapshotStorageInBy/$IngestedLocalStorageInB)*100),1)
    $result.Add("LocalDataReductionPercent",$LocalDataReduction)
    $EstimatedRunwayInDays = [Math]::round(($AvailableStorageInBy/$DailyGrowthInBy)) 
    $result.Add("EstimatedRunwayInDays", $EstimatedRunwayInDays)
    return $result

  } # End of process
} # End of function