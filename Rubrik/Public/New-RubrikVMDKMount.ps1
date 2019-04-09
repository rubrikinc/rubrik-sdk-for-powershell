#Requires -Version 3
function New-RubrikVMDKMount
{
  <#  
      .SYNOPSIS
      Create a new live mount of a VMDK
      
      .DESCRIPTION
      The New-RubrikVMDKMount cmdlet is used to create a new mount of a specific virtual disk (vmdk) on the TargetVM of the selected Snapshot.      
      
      .NOTES
      Written by Pierre Flammer for community usage
      Twitter: @PierreFlammer
      
      .LINK
      http://rubrikinc.github.io/rubrik-sdk-for-powershell/

      .PARAMETER
      ATTENTION: Names have to match the names configured in Rubrik!!!
      SnapshotID: ID of the Rubrik snaphot of the source VM
      TargetVM: Name of the VM where the VMDK(s) will be mounted
      AllDisks: If this parameter is used all VMDKs will be mounted to the target VM. 
                If one has to enter a number and select one VMDK.
      VLAN: Specify the VLAN number

      .EXAMPLE
      New-RubrikVMDKMount -snapshotid 'cc1b363a-a0d4-40b7-9b09-7b8f3a805b27' -TargetVM 'VM2' 
      
      New-RubrikVMDKMount -snapshotid 'cc1b363a-a0d4-40b7-9b09-7b8f3a805b27' -TargetVM 'VM2' -AllDisks -VLAN 50
     
  #>

  [CmdletBinding()]
  Param(
    # Target host to attach the Live Mount disk(s)
    [Parameter(Position = 0,ValueFromPipelineByPropertyName = $true)]
    [Alias('id')]
    [String]$SnapshotID,
    [Parameter(Mandatory=$true)]
    [String]$TargetVM,
    [parameter(Mandatory=$false)]
    [Switch]$AllDisks,
    [parameter(Mandatory=$false)]
    [Int]$VLAN,
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

    $uri = New-URIString -server $Server -endpoint ($resources.URI) -id $snapshotid
    $uri = Test-QueryParam -querykeys ($resources.Query.Keys) -parameters ((Get-Command $function).Parameters.Values) -uri $uri
        
    $TargetID = Get-RubrikVM -name $TargetVM
    $TargetID = $TargetID.id

    Write-Verbose -Message "Build the body"

    $body = @{
        $resources.Body.targetVmId = $TargetID
        vmdkIds = @() 
    }

    # Disk configuration
    $snapdiskdetails = Get-RubrikVMSnapshot -id $snapshotid 
    #$snapdiskdetails = Get-RubrikVMSnapshot -id 'cc1b363a-a0d4-40b7-9b09-7b8f3a805b27'
    if ($AllDisks) {
        #Parameter -AllDisks was used -> Mount all VMDKs
        foreach ($disk in $snapdiskdetails.snapshotDiskDetails)
        {
            $body.vmdkIds += $disk.virtualDiskId
        }
    } else {
        #Get List of VMDKs and mount the selected one
        "Please select a VMDK to use:" | Out-Host
        "--------------------------------" | Out-Host
        $snapdiskdetails.snapshotDiskDetails  | ForEach-Object -Begin {$i=0} -Process {"VMDK $i - $($_.filename)";$i++} | Out-Host
        $selection = Read-Host 'Enter ID of selected VMDK'

        $body.vmdkIds += $snapdiskdetails.snapshotDiskDetails[$selection].virtualDiskId
    }

    $body = ConvertTo-Json $body
    Write-Verbose -Message "Body = $body"

    $result = Submit-Request -uri $uri -header $Header -method $($resources.Method) -body $body
    $result = Test-ReturnFormat -api $api -result $result -location $resources.Result
    $result = Test-FilterObject -filter ($resources.Filter) -result $result

    return $result

  } # End of process
} # End of function