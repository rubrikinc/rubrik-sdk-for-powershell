#Requires -Version 3
function Invoke-RubrikHvmFormatUpgrade
{
  <#
      .SYNOPSIS
      Connects to Rubrik and sets the forceFullSpec flag of any number of Hyper-V Virtual Machines that needs upgrade. It sets the VirtualDiskInfos to empty(default)
      so that all the disks present within the VM gets set up for a full.

      .DESCRIPTION
      The Invoke-RubrikHvmFormatUpgrade cmdlet will update the forceFullSpec of a given list of Hyper-V Virtual Machines.
      If these Hyper-V Virtual Machines are using the SMB backup method, their forceFull flag will be set, and they will be upgraded to use the fast VHDX method in the next backup.

      .NOTES
      Written by Abhinav Prakash for community usage
      github: ab-prakash

      .LINK
      https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/invoke-rubrikhvmformatupgrade

      .EXAMPLE
      Invoke-RubrikHvmFormatUpgrade -VMList HypervVirtualMachine:::e0a04776-ab8e-45d4-8501-8da658221d74, HypervVirtualMachine:::9136a7ef-4ad2-4bb9-bf28-961fb74d4322

      This will set the forceFullspec of the given Hyper-V Virtual Machines to default, which will force a full.

      .EXAMPLE
      Get-RubrikVVM -hostname ad.flammi.home | Invoke-RubrikHvmFormatUpgrade
      
      This will set the forceFullSpec of the Hyper-V Virtual Machine to default belonging to the specified hostname, which will force a full
  #>

  [CmdletBinding(SupportsShouldProcess = $true,ConfirmImpact = 'High',DefaultParameterSetName="None")]
  Param(
    # HypervVirtualMachine ID
    [Parameter(Mandatory = $true,ValueFromPipelineByPropertyName = $true)]
    [ValidateNotNullOrEmpty()]
    [String[]]$VMList,
    # Print details during confirmation
    [switch]$notPrintingDetail,
    [String]$body,
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

    #get all Hyper-V Virtual Machines format report
    $hvmFormatReport = Get-RubrikHvmFormatReport

    #filter Hyper-V Virtual Machines by input and need for upgrade
    $vmIdsToUpgrade = @()
    $vmIdToNameMap = @{}
    foreach ($hvmFormat in $hvmFormatReport) {
      if ($VMList.Contains($hvmFormat.ID)) {
        if($hvmFormat.usedFastVhdx) {
          Write-Host "Skipping upgrade on $($hvmFormat.ID) since its latest snapshot is already in the new fast VHDX format."
        }
        else {
          $vmIdsToUpgrade += $hvmFormat.ID
          $vmIdToNameMap.Add($hvmFormat.ID, $hvmFormat.VmName)
        }
      }
    }

    if ($vmIdsToUpgrade.count -eq 0) {
        Write-Host "No Hyper-V Virtual Machine to upgrade."
        return $null
    }

    #confirm action
    $promptString = "This command will set the following Hyper-V Virtual Machines for format upgrade:

$($vmIdToNameMap.Values -join "`r`n")
"
    if ($notPrintingDetail) {
      $promptString = ""
    }

    $confirmation = Read-Host "$promptString
Do you want to proceed? (y/N) "

    if ($confirmation -ne 'y') {
      return $null
    }

    #invoke upgrade by setting forceFullSpec to default for each Hyper-V Virtual Machine
    foreach ($id in $vmIdsToUpgrade) {
      Write-Host "Setting $($vmIdToNameMap[$id]) for format upgrade on next backup..."
      $uri = New-URIString -server $Server -endpoint ($resources.URI) -id $id
      $uri = Test-QueryParam -querykeys ($resources.Query.Keys) -parameters @($id) -uri $uri
      Write-Output $uri
      
      #add empty virtualDiskInfos to body
      $body = New-Object -TypeName PSObject -Property @{'virtualDiskInfos'=@()} | ConvertTo-Json -Depth 10
      $result = Submit-Request -uri $uri -header $Header -method $($resources.Method) -body $body
      $result = Test-ReturnFormat -api $api -result $result -location $resources.Result
      $result = Set-ObjectTypeName -TypeName $resources.ObjectTName -result $result
      Write-Verbose "Done for $id with result $result"
    }
    Write-Host ""
    Write-Host "Successfully set the following Hyper-V Virtual Machines for upgrade on the next backup:"
    Write-Host ($hvmFormatReport | Where-Object {$vmIdsToUpgrade.contains($_.ID)} | Select-Object -ExpandProperty VmName)
  } # End of process
} # End of function
