#requires -Version 3
function Stop-RubrikVM
{
  <#  
      .SYNOPSIS
      Powers off a live mounted virtual machine within a connected Rubrik vCenter.

      .DESCRIPTION
      The Stop-RubrikVM cmdlet is used to send a power off request to any virtual machine visible to a Rubrik cluster.

      .NOTES
      Written by Chris Wahl for community usage
      Twitter: @ChrisWahl
      GitHub: chriswahl

      .LINK
      https://github.com/rubrikinc/PowerShell-Module

      .EXAMPLE
      Stop-RubrikVM -VM 'Server1'
      This will send a power off request to Server1
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

  Process {

    TestRubrikConnection
    
    Write-Verbose -Message 'Determining which version of the API to use'
    $resources = GetRubrikAPIData -endpoint ('VMwareVMMountPowerPost')

    Write-Verbose -Message 'Gathering the live mount VM ID and building the body'
    Switch ($api) {
      'v0' 
      {
        $vmid = ((Get-RubrikMount -VM $VM).virtualMachine.id)
        $body = @{
          $resources.$api.Params.vmId = $vmid
          $resources.$api.Params.powerStatus = $false
        }
      }
      default 
      {
        $vmid = ((Get-RubrikMount -VM $VM).id)
        $body = @{
          $resources.$api.Params.powerStatus = $false
        } 
      }
    }

    Write-Verbose -Message 'Building the URI'
    $uri = 'https://'+$Server+$resources.$api.URI
    # Replace the placeholder of {id} with the actual VM ID
    $uri = $uri -replace '{id}', $vmid
    
    # Set the method
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