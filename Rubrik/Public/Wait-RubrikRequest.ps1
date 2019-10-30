#Requires -Version 3
function Wait-RubrikRequest {
      <#  
      .SYNOPSIS
      Connects to Rubrik and retrieves details on an async request
            
      .DESCRIPTION
      The Get-RubrikRequestInfo cmdlet will pull details on a request that was submitted to the distributed task framework and wait for that specific task to complete
      This is helpful for tracking the state (success, failure, running, etc.) of a request and waiting for that specific task to complete. 
            
      .NOTES
      Written by Chris Lumnah
      Twitter: @lumnah
      GitHub: clumnah
            
      .LINK
      http://rubrikinc.github.io/rubrik-sdk-for-powershell/reference/Get-RubrikRequest.html
            
      .EXAMPLE
      Get-RubrikRequestInfo -RurbikRequestId 'MOUNT_SNAPSHOT_123456789:::0' -Type 'vmware/vm'
      Will return details about an async VMware VM request named "MOUNT_SNAPSHOT_123456789:::0" and wait for it to complete
  #>
    param(
        # Rubrik Request Object Info
        [Parameter(Mandatory = $true)]
        [string]$RubrikRequestID,
        # The type of request
        [Parameter(Mandatory = $true)]
        [ValidateSet('fileset', 'mssql', 'vmware/vm', 'hyperv/vm', 'managed_volume')]
        [String]$Type
    )
    
    $ExitList = @("SUCCEEDED", "FAILED")
    do {
        $RubrikRequestInfo = Get-RubrikRequest -id $RubrikRequestId -Type $Type
        If ($RubrikRequestInfo.progress -gt 0) {
            Write-Debug "$($RubrikRequestInfo.id) is $($RubrikRequestInfo.status) $($RubrikRequestInfo.progress) complete"
            Write-Progress -Activity "$($RubrikRequestInfo.id) is $($RubrikRequestInfo.status)" -status "Progress $($RubrikRequestInfo.progress)" -percentComplete ($RubrikRequestInfo.progress)
        }
        else {
            Write-Progress -Activity "$($RubrikRequestInfo.id)" -status "Job Queued" -percentComplete (0)
        }
        Start-Sleep -Seconds 1
    } while ($RubrikRequestInfo.status -notin $ExitList) 	
    return Get-RubrikRequest -id $RubrikRequestId -Type $Type
}