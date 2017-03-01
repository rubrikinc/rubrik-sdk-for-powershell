#Requires -Version 3
function New-RubrikMount
{
  <#  
      .SYNOPSIS
      Create a new Live Mount from a protected VM
      
      .DESCRIPTION
      The New-RubrikMount cmdlet is used to create a Live Mount (clone) of a protected VM and run it in an existing vSphere environment.
      
      .NOTES
      Written by Chris Wahl for community usage
      Twitter: @ChrisWahl
      GitHub: chriswahl
      
      .LINK
      https://github.com/rubrikinc/PowerShell-Module
      
      .EXAMPLE
      New-RubrikMount -VM 'Server1' -Date '05/04/2015 08:00'
      This will create a new Live Mount for the virtual machine named Server1 based on the first snapshot that is equal to or older than 08:00 AM on May 4th, 2015
      
      .EXAMPLE
      New-RubrikMount -VM 'Server1'
      This will create a new Live Mount for the virtual machine named Server1 based on the first snapshot that is equal to or older the current time (now)
  #>

  [CmdletBinding(SupportsShouldProcess = $true,ConfirmImpact = 'High')]
  Param(
    # Name of the virtual machine
    [Parameter(Mandatory = $true,Position = 0,ValueFromPipelineByPropertyName = $true)]
    [Alias('Name')]
    [ValidateNotNullorEmpty()]
    [String]$VM,
    # An optional name for the Live Mount
    # By default, will use the original VM name plus a date and instance number
    [Parameter(Position = 1)]
    [String]$MountName,
    # Date of the snapshot to use for the Live Mount
    # Format should match MM/DD/YY HH:MM
    # If no value is specified, will retrieve the last known shapshot
    [Parameter(Position = 2,ValueFromPipelineByPropertyName = $true)]
    [ValidateNotNullorEmpty()]
    [String]$Date,
    # ID of the host for the Live Mount to use
    # Defaults to the hostId where the running virtual machine lives
    [String]$HostID,
    # Select the power state of the Live Mount
    # Defaults to $false (powered off)
    [Switch]$PowerOn,
    # Rubrik server IP or FQDN
    [String]$Server = $global:RubrikConnection.server,
    # API version
    [String]$api = $global:RubrikConnection.api
  )

  Begin {

    Test-RubrikConnection
        
    Write-Verbose -Message 'Gather API data'
    $resources = Get-RubrikAPIData -endpoint ('VMwareVMMountPost')
  
  }

  Process {

    if (!$Date) 
    {
      Write-Verbose -Message 'No date entered. Taking current time.'
      $Date = Get-Date
    }

    Write-Verbose -Message 'Query Rubrik for the list of protected VM details'
    if (!$HostID)
    {
      $HostID = (Get-RubrikVM -VM $VM).hostId
    }

    Write-Verbose -Message 'Query Rubrik for the protected VM snapshot list'
    $snapshots = Get-RubrikSnapshot -VM $VM

    Write-Verbose -Message 'Comparing backup dates to user date'
    $Date = ConvertFrom-LocalDate -Date $Date
        
    Write-Verbose -Message 'Finding snapshots that match the date value'
    foreach ($_ in $snapshots)
    {
      if (([datetime]$_.date) -le ($Date) -eq $true)
      {
        $vmsnapid = $_.id
        Write-Verbose -Message "Found matching snapshot with ID $vmsnapid"
        break
      }
    }

    Write-Verbose -Message 'Build the URI'
    $uri = 'https://'+$Server+$resources.$api.URI
    
    # Create the body
    $body = @{
      $resources.$api.body.snapshotId = $vmsnapid
      $resources.$api.body.hostId = $HostID
      $resources.$api.body.disableNetwork = $true
      $resources.$api.body.removeNetworkDevices = $false
      $resources.$api.body.powerOn = [boolean]::Parse($PowerOn)
    }
    
    if ($MountName) 
    {
      $body.Add($resources.$api.body.vmName,$MountName)
    }
        
    Write-Verbose -Message 'Build the method'
    $method = $resources.$api.Method

    try 
    {
      if ($PSCmdlet.ShouldProcess($VM,'Creating a new Live Mount'))
      {
        $r = Invoke-WebRequest -Uri $uri -Headers $Header -Method $method -Body (ConvertTo-Json -InputObject $body)
        if ($r.StatusCode -ne $resources.$api.SuccessCode) 
        {
          Write-Warning -Message 'Did not receive successful status code from Rubrik for Live Mount request'
          throw $_
        }
        $response = ConvertFrom-Json -InputObject $r.Content
        return $response
      }
    }
    catch 
    {
      throw $_
    }

  } # End of process
} # End of function