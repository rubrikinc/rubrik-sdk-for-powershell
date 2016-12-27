#Requires -Version 3
function New-RubrikSnapshot
{
  <#  
      .SYNOPSIS
      Takes a Rubrik snapshot of a virtual machine

      .DESCRIPTION
      The New-RubrikSnapshot cmdlet will trigger an on-demand snapshot for a specific virtual machine. This will be taken by Rubrik and stored in the VM's chain of snapshots.

      .NOTES
      Written by Chris Wahl for community usage
      Twitter: @ChrisWahl
      GitHub: chriswahl

      .LINK
      https://github.com/rubrikinc/PowerShell-Module

      .EXAMPLE
      New-RubrikSnapshot -VM 'Server1'
      This will trigger an on-demand backup for the virtual machine named Server1
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
    $resources = GetRubrikAPIData -endpoint ('VMwareVMBackupPost')

    Write-Verbose -Message 'Gathering VM ID value from Rubrik'
    $vmid = (Get-RubrikVM -VM $VM).id

    Write-Verbose -Message 'Building the URI'
    $uri = 'https://'+$Server+$resources.$api.URI
    # Replace the placeholder of {id} with the actual VM ID
    $uri = $uri -replace '{id}', $vmid

    # v0 API Body is required for passing along the ID
    if ($api -eq 'v0') 
    {
      Write-Verbose -Message 'Build the body'

      $body = @{
        vmId = $vmid
      }
    }
    # v1+ API uses the VM ID in the URI
    # The Invoke-WebRequest cmdlet will just overlook the body
    else 
    {
      $body = $null
    }

    # Set the method
    $method = $resources.$api.Method

    Write-Verbose -Message 'Submit the request'
    try
    {
      $r = Invoke-WebRequest -Uri $uri -Headers $Header -Method $method -Body (ConvertTo-Json -InputObject $body)
      if ($r.StatusCode -ne $resources.$api.SuccessCode) 
      {
        Write-Warning -Message 'Did not receive successful status code from Rubrik'
        throw $_
      }
      $response = ConvertFrom-Json -InputObject $r.Content
      return $response
    }
    catch
    {
      throw $_
    }


  } # End of process
} # End of function