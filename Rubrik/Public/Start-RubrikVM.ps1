#requires -Version 3
function Start-RubrikVM
{
  <#  
      .SYNOPSIS
      Powers on a live mounted virtual machine within a connected Rubrik vCenter.

      .DESCRIPTION
      The Stop-RubrikVM cmdlet is used to send a power on request to any virtual machine visible to a Rubrik cluster.

      .NOTES
      Written by Chris Wahl for community usage
      Twitter: @ChrisWahl
      GitHub: chriswahl

      .LINK
      https://github.com/rubrikinc/PowerShell-Module

      .EXAMPLE
      Start-RubrikVM -VM 'Server1'
      This will send a power on request to Server1
  #>

  [CmdletBinding(SupportsShouldProcess = $true,ConfirmImpact = 'High')]
  Param(
    # Virtual machine name
    [Parameter(Mandatory = $true,Position = 0,ValueFromPipelineByPropertyName = $true)]
    [Alias('Name')]
    [ValidateNotNullorEmpty()]
    [String]$VM,
    # Rubrik server IP or FQDN
    [Parameter(Position = 1)]
    [String]$Server = $global:RubrikConnection.server,
    # API version
    [Parameter(Position = 2)]
    [String]$api = $global:RubrikConnection.api
  )

  Begin {

    Test-RubrikConnection
        
    Write-Verbose -Message 'Gather API data'
    $resources = Get-RubrikAPIData -endpoint ('VMwareVMMountPowerPost')
  
  }

  Process {

    Write-Verbose -Message 'Gathering the live mount VM ID and building the body'
    Switch ($api) {
      'v0' 
      {
        $vmid = ((Get-RubrikMount -VM $VM).virtualMachine.id)
        $body = @{
          $resources.$api.Params.vmId = $vmid
          $resources.$api.Params.powerStatus = $true
        }
      }
      default 
      {
        $vmid = ((Get-RubrikMount -VM $VM).id)
        $body = @{
          $resources.$api.Params.powerStatus = $true
        } 
      }
    }

    Write-Verbose -Message 'Build the URI'
    $uri = 'https://'+$Server+$resources.$api.URI
    # Replace the placeholder of {id} with the actual VM ID
    $uri = $uri -replace '{id}', $vmid
    
    Write-Verbose -Message 'Build the method'
    $method = $resources.$api.Method

    try
    {
      if ($PSCmdlet.ShouldProcess($VM,'Power off live mount'))
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