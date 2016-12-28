#requires -Version 3
function Set-RubrikVM
{
  <#  
      .SYNOPSIS
      Applies settings on one or more virtual machines known to a Rubrik cluster

      .DESCRIPTION
      The Set-RubrikVM cmdlet is used to apply updated settings from a Rubrik cluster on any number of virtual machines

      .NOTES
      Written by Chris Wahl for community usage
      Twitter: @ChrisWahl
      GitHub: chriswahl

      .LINK
      https://github.com/rubrikinc/PowerShell-Module

      .EXAMPLE
      Set-RubrikVM -VM 'Server1' -SnapConsistency AUTO
      This will configure the backup consistency type for Server1 to Automatic (try for application consistency and fail to crash consistency).

      .EXAMPLE
      (Get-RubrikVM -VM * -SLA 'Example').name | Set-RubrikVM -SnapConsistency AUTO
      This will gather the name of all VMs belonging to the SLA Domain named Example and configure the backup consistency type to be crash consistent.
  #>

  [CmdletBinding()]
  Param(
    # Virtual machine name
    [Parameter(Mandatory = $true,Position = 0,ValueFromPipelineByPropertyName = $true)]
    [Alias('Name')]
    [ValidateNotNullorEmpty()]
    [String]$VM,
    # Backup consistency type
    # Choices are AUTO or CRASH_CONSISTENT
    [Parameter(Position = 1)]
    [ValidateSet('APP_CONSISTENT', 'CRASH_CONSISTENT','FILE_SYSTEM_CONSISTENT','INCONSISTENT','VSS_CONSISTENT')]
    [String]$SnapConsistency,
    # The number of existing virtual machine snapshots allowed by Rubrik
    # If this value is exceeded, backups will be prevented due to seeing too many existing snapshots
    # Keeping snapshots open on a virtual machine can adversely affect performance and increase consolidation times
    # Choices range from 0 - 4 snapshots
    [Parameter(Position = 2)]
    [ValidateRange(0,4)] 
    [int]$MaxNestedSnapshots,
    # Set to $true to enable backups for a particular virtual machine
    # Set to $false to disable backups for a particular virtual machine
    [Parameter(Position = 3)]
    [ValidateSet('True','False')]    
    [String]$PauseBackups,
    # Rubrik server IP or FQDN
    [String]$Server = $global:RubrikConnection.server,
    # API version
    [String]$api = $global:RubrikConnection.api
  )

  Process {

    TestRubrikConnection

    Write-Verbose -Message 'Determining which version of the API to use'
    $resources = GetRubrikAPIData -endpoint ('VMwareVMPatch')

    Write-Verbose -Message 'Gathering VM ID value from Rubrik'
    $vmid = (Get-RubrikVM -VM $VM).id

    Write-Verbose -Message 'Building the URI'
    $uri = 'https://'+$Server+$resources.$api.URI
    # Replace the placeholder of {id} with the actual VM ID
    $uri = $uri -replace '{id}', $vmid
    
    # Set the method
    $method = $resources.$api.Method
    
    Write-Verbose -Message 'Defining a body variable for required API params'
    $body = @{}

    if ($SnapConsistency)
    {
      Write-Verbose -Message 'Adding snapshotConsistencyMandate to Body'
      $body.Add($resources.$api.Params.snapshotConsistencyMandate,$SnapConsistency)
    }
    if ($MaxNestedSnapshots)
    {
      Write-Verbose -Message 'Adding maxNestedVsphereSnapshots to Body'
      $body.Add($resources.$api.Params.maxNestedVsphereSnapshots,$MaxNestedSnapshots)
    }    
    if ($PauseBackups)
    {
      Write-Verbose -Message 'Adding isVmPaused to Body'
      $body.Add($resources.$api.Params.isVmPaused,[System.Convert]::ToBoolean($PauseBackups))
    } 
    
    # If the $body variable is empty, no params were defined
    if ($body.Keys.Count -eq 0)
    {
      throw 'No parameters were defined.'
    }

    try
    {
      if ($PSCmdlet.ShouldProcess($VM,'Modifying settings'))
      {
        $r = Invoke-WebRequest -Uri $uri -Headers $Header -Method $method -Body (ConvertTo-Json -InputObject $body)
        if ($r.StatusCode -ne $resources.$api.SuccessCode) 
        {
          Write-Warning -Message 'Did not receive successful status code from Rubrik'
          throw $_
        }
      }
    }
    catch
    {
      throw $_
    }

  } # End of process
} # End of function