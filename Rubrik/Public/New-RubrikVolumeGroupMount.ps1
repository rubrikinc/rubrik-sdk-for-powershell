#Requires -Version 3
function New-RubrikVolumeGroupMount
{
  <#  
      .SYNOPSIS
      Create a new live mount of a protected volume group
      
      .DESCRIPTION
      The New-RubrikVolumeGroupMount cmdlet is used to create a new volume group mount on the TargetHost of the selected Snapshot.
      The Snapshot object contains the snapID and all drives that are included in the snapshot.
      
      .NOTES
      Written by Pierre Flammer for community usage
      Twitter: @PierreFlammer
      
      .LINK
      https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/new-rubrikvolumegroupmount

      .EXAMPLE
      New-RubrikVolumeGroupMount -TargetHost 'Restore-Server1' -VolumeGroupSnapshot $snap -ExcludeDrives -$DrivestoExclude

      This will create a new VolumeGroup Mount on Restore-Server1 with the values specified in $snap & $DrivestoExclude

      .EXAMPLE
      $snapshot = Get-RubrikVolumeGroup "MyVolumeGroup" | Get-RubrikSnapshot -Latest
      New-RubrikVolumeGroupMount -TargetHost "MyTargetHostName" -VolumeGroupSnapshot $snapshot -ExcludeDrives @("D","E")
      New-RubrikVolumeGroupMount -TargetHost "MyTargetHostName" -VolumeGroupSnapshot $snapshot -ExcludeMountPoint @("C:\MFAPDB05Log\")

      To exclude all MountPoints with a certain string 
      New-RubrikVolumeGroupMount -TargetHost "MyTargetHostName" -VolumeGroupSnapshot $snapshot -ExcludeMountPoint @("Log")

      This will create a new VolumeGroup Mount on MyTargetHostName with the latest snapshot retrieved in the first line, while exlcluding drives D & E
  #>

  [CmdletBinding(SupportsShouldProcess = $true,ConfirmImpact = 'High')]
  Param(
    # Target host to attach the Live Mount disk(s)
    [Parameter(Mandatory=$true)]
    [String]$TargetHost,
    # Rubrik VolumeGroup Snapshot Array
    [Parameter(Mandatory = $true)]
    [object]$VolumeGroupSnapshot,
    # Rubrik server IP or FQDN
    [Parameter(ParameterSetName = 'Create')]
    [Array]$ExcludeDrives,
    [Array]$ExcludeMountPoints,
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

    $uri = New-URIString -server $Server -endpoint ($resources.URI) -id $VolumeGroupSnapshot.id
    $uri = Test-QueryParam -querykeys ($resources.Query.Keys) -parameters ((Get-Command $function).Parameters.Values) -uri $uri
        
    $TargetHostID = Get-RubrikHost -name $TargetHost
    $TargetHostID = $TargetHostID.id

    Write-Verbose -Message "Build the body"
    
    $body = @{
        $resources.Body.targetHostid = $TargetHostID
        volumeConfigs = @()
        $resources.Body.smbValidUsers = @()
    }

    foreach ($disk in $VolumeGroupSnapshot.includedVolumes)
    {
        if ($ExcludeDrives -contains $disk.mountPoints.Replace(":\","") -Or [bool]($disk.mountPoints -match $ExcludeMountPoints) )
        {
            Write-Verbose -Message "Disk/MountPoint $disk.mountPoints is excluded" -Verbose
        } 
        else 
        {
            $body.volumeConfigs += @{$resources.body.volumeConfigs.volumeId = $disk.id
            $resources.body.volumeConfigs.mountpointonhost = 'c:\rubrik-mounts\Disk-' + $disk.mountpoints.Replace(':','').Replace('\','')}
        }
    }

    $body = ConvertTo-Json $body

    Write-Verbose -Message "Body = $body"
    #endregion

    $result = Submit-Request -uri $uri -header $Header -method $($resources.Method) -body $body
    $result = Test-ReturnFormat -api $api -result $result -location $resources.Result
    $result = Test-FilterObject -filter ($resources.Filter) -result $result

    return $result

  } # End of process
} # End of function