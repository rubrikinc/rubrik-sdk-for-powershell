#Requires -Version 3
function Protect-RubrikVM
{
  <#
      .SYNOPSIS
      Connects to Rubrik and assigns an SLA to a virtual machine
            
      .DESCRIPTION
      The Protect-RubrikVM cmdlet will update a virtual machine's SLA Domain assignment within the Rubrik cluster. The SLA Domain contains all policy-driven values needed to protect workloads.
            
      .NOTES
      Written by Chris Wahl for community usage
      Twitter: @ChrisWahl
      GitHub: chriswahl
            
      .LINK
      https://github.com/rubrikinc/PowerShell-Module
            
      .EXAMPLE
      Protect-RubrikVM -VM 'Server1' -SLA 'Gold'
      This will assign the Gold SLA Domain to a VM named Server1
            
      .EXAMPLE
      Protect-RubrikVM -VM 'Server1' -Unprotect
      This will remove the SLA Domain assigned to Server1, thus rendering it unprotected
  #>

  [CmdletBinding(SupportsShouldProcess = $true,ConfirmImpact = 'High')]
  Param(
    # Virtual machine name
    [Parameter(Mandatory = $true,Position = 0,ValueFromPipelineByPropertyName = $true)]
    [Alias('Name')]
    [ValidateNotNullorEmpty()]
    [String]$VM,
    # The SLA Domain in Rubrik
    [Parameter(Position = 1)]
    [ValidateNotNullorEmpty()]
    [String]$SLA,
    # Removes the SLA Domain assignment
    [Parameter(Position = 2)]
    [ValidateNotNullorEmpty()]
    [Switch]$DoNotProtect,
    # Inherits the SLA Domain assignment from a parent object
    [Parameter(Position = 3)]
    [ValidateNotNullorEmpty()]
    [Switch]$Inherit,
    # Rubrik server IP or FQDN
    [Parameter(Position = 2)]
    [String]$Server = $global:RubrikConnection.server,
    # API version
    [Parameter(Position = 3)]
    [ValidateNotNullorEmpty()]
    [String]$api = $global:RubrikConnection.api
  )

  Process {

    TestRubrikConnection

    Write-Verbose -Message 'Matching the SLA input to a valid Rubrik SLA Domain'
    try
    {
      if ($DoNotProtect)
      {
        Write-Verbose -Message 'Setting VM protection level to DO NOT PROTECT (block inheritence)'
        $slaMatch = @{}
        $slaMatch.id = 'UNPROTECTED'
        $slaMatch.name = 'Unprotected'
      }
      elseif ($Inherit)
      {
        Write-Verbose -Message 'Setting VM protection level to INHERIT (from parent object)'
        $slaMatch = @{}
        $slaMatch.id = 'INHERIT'
        $slaMatch.name = 'Inherit'
      }
      else
      {
        $slaMatch = Get-RubrikSLA -SLA $SLA
      }
      if ($slaMatch -eq $null)
      {
        throw 'Use either SLA, DoNotProtect, or Inherit to change the protection status of the VM'
      }
    }
    catch
    {
      throw $_
    }

    Write-Verbose -Message 'Gathering VM ID value from Rubrik'
    [array]$vmids = (Get-RubrikVM -VM $VM).id

    Write-Verbose -Message 'Walking through all IDs found'
    foreach ($vmid in $vmids) 
    {
      Write-Verbose -Message "Updating SLA Domain for ID $vmid"
      $uri = 'https://'+$Server+'/vm/'+$vmid
      $body = @{
        slaDomainId = $slaMatch.id
      }

      try
      {
        if ($PSCmdlet.ShouldProcess($vmid,"Assign $SLA SLA Domain"))
        {
          $r = Invoke-WebRequest -Uri $uri -Headers $header -Body (ConvertTo-Json -InputObject $body) -Method Patch
          if ($r.StatusCode -ne '200')
          {
            throw $r.StatusDescription
          }
          $result = (ConvertFrom-Json -InputObject $r.Content)
          Write-Verbose -Message "$($result.name) set to $($result.slaDomain.name) SLA Domain"
        }
      }
      catch
      {
        throw $_
      }
    }


  } # End of process
} # End of function
