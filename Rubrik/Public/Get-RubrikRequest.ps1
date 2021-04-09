#Requires -Version 3
function Get-RubrikRequest {
  <#  
    .SYNOPSIS
    Connects to Rubrik and retrieves details on an async request

    .DESCRIPTION
    The Get-RubrikRequest cmdlet will pull details on a request that was submitted to the distributed task framework.
    This is helpful for tracking the state (success, failure, running, etc.) of a request.

    .NOTES
    Written by Chris Wahl for community usage
    Twitter: @ChrisWahl
    GitHub: chriswahl

    .LINK
    https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/get-rubrikrequest

    .EXAMPLE
    Get-RubrikRequest -id 'MOUNT_SNAPSHOT_123456789:::0' -Type 'vmware/vm'

    Will return details about an async VMware VM request named "MOUNT_SNAPSHOT_123456789:::0"

    .EXAMPLE
    Get-RubrikRequest -id 'MOUNT_SNAPSHOT_123456789:::0' -Type 'vmware/vm'

    Will wait for the specified async request to report a 'SUCCESS' or 'FAILED' status before returning details

    .EXAMPLE
    Get-RubrikVM jbrasser-lin | Get-RubrikSnapshot -Latest | New-RubrikMount -MountName 'SuperCoolVM' | Get-RubrikRequest -WaitForCompletion -Verbose

    Will take the latest Snapshot of jbrasser-lin and create a live mount of this Virtual Machine, Get-RubrikRequest will poll the cluster until the VM is available while displaying Verbose information.

    .EXAMPLE
    Update-RubrikVCenter vCenter:::111 | Get-RubrikRequest -WaitForCompletion

    Updates Rubrik vCenter and waits for completion of the request
  #>

  [CmdletBinding()]
  Param(
    # ID of an asynchronous request
    [Parameter(
      Mandatory = $true,
      ValueFromPipelineByPropertyName = $true,
      ParameterSetName = 'Entry'
    )]
    [String]$id,
    # The type of request
    [Parameter(
      Mandatory = $true,
      ParameterSetName = 'Entry'
    )]
    [ValidateSet(
      'fileset', 'mssql', 'vmware/vm', 'hyperv/vm', 'hyperv/scvmm',
      'managed_volume', 'volume_group', 'nutanix/vm', 'aws/ec2_instance',
      'oracle','vcd/vapp', 'vcd/cluster', 'vmware/vcenter', 'cloud_on/azure',
      'report', 'nutanix/cluster', 'vmware/compute_cluster', 'sla_domain',
      'backup/verify'
    )]
    [String]$Type,    
    # Request
    [Parameter(
      Mandatory = $true,
      ParameterSetName = 'Pipeline',
      ValueFromPipeline = $true
    )]
    [pscustomobject]$Request,
    # Wait for Request to Complete
    [Switch]$WaitForCompletion,
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

    $uri = New-URIString -server $Server -endpoint ($resources.URI) -id $id

    #region one-off
    $uri = $uri -replace '{type}', $Type

    #Place any internal API request calls into this collection, the replace will fix the URI
    $internaltypes = @(
      'managed_volume','volume_group','nutanix/vm','aws/ec2_instance','oracle',
      'vcd/vapp', 'cloud_on/azure', 'hyperv/scvmm', 'vcd/cluster', 'report', 'nutanix/cluster'
    )
    $v2types = @('sla_domain')

    if ($internaltypes -contains $Type) {
      $uri = $uri -replace 'v1', 'internal'
    } elseif ($v2types -contains $Type) {
      $uri = $uri -replace 'v1', 'v2'
    } elseif ($Type -eq 'backup/verify') {
      $uri = $uri -replace 'request/'
    }

    #endregion

    $uri = Test-QueryParam -querykeys ($resources.Query.Keys) -parameters ((Get-Command $function).Parameters.Values) -uri $uri
    $body = New-BodyString -bodykeys ($resources.Body.Keys) -parameters ((Get-Command $function).Parameters.Values)    

    if ($Request) {
      Write-Verbose "Using uri supplied by pipeline: $($Request.links.href)"
      $uri = $Request.links.href
      
      # Fix for 5.3
      if ($uri -match 'backup_verification') {
        $uri = $uri -replace 'backup_verification/request', 'backup/verify'
      }
    }
    
    #We added new code that will now wait for the Rubrik Async Request to complete. Once completion has happened, we return back the request object. 
    #region WaitForCompletion
    if ($WaitForCompletion) {
      $ExitList = @("SUCCEEDED", "FAILED")
      do {
        $result = Submit-Request -uri $uri -header $Header -method $($resources.Method) -body $body
        $result = Test-ReturnFormat -api $api -result $result -location $resources.Result
        $result = Test-FilterObject -filter ($resources.Filter) -result $result
        If ($result.progress -gt 0) {
          Write-Verbose "$($result.id) is $($result.status) $($result.progress) complete"
          Write-Progress -Activity "$($result.id) is $($result.status)" -status "Progress $($result.progress)" -percentComplete ($result.progress)
        }
        else {
          Write-Progress -Activity "$($result.id)" -status "Job Queued" -percentComplete (0)
        }
        if ($result.status -notin $ExitList) {
          Start-Sleep -Seconds 5
        }
      } while ($result.status -notin $ExitList) 	
    }
    #endregion
    $result = Submit-Request -uri $uri -header $Header -method $($resources.Method) -body $body
    $result = Test-ReturnFormat -api $api -result $result -location $resources.Result
    $result = Test-FilterObject -filter ($resources.Filter) -result $result
    return $result
  } # End of process
} # End of function