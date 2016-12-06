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
  #>

  [CmdletBinding(SupportsShouldProcess = $true,ConfirmImpact = 'High')]
  Param(
    # Virtual machine name
    [Parameter(Mandatory = $true,Position = 0,ValueFromPipelineByPropertyName = $true)]
    [Alias('Name')]
    [ValidateNotNullorEmpty()]
    [String]$VM,
    # The SLA Domain in Rubrik
    [Parameter(Position = 1,ParameterSetName = 'SLA_Explicit')]
    [String]$SLA,
    # Removes the SLA Domain assignment
    [Parameter(Position = 2,ParameterSetName = 'SLA_Unprotected')]
    [Switch]$DoNotProtect,
    # Inherits the SLA Domain assignment from a parent object
    [Parameter(Position = 3,ParameterSetName = 'SLA_Inherit')]
    [Switch]$Inherit,
    # Rubrik server IP or FQDN
    [Parameter(Position = 4)]
    [String]$Server = $global:RubrikConnection.server,
    # API version
    [Parameter(Position = 5)]
    [String]$api = $global:RubrikConnection.api
  )

  Process {

    TestRubrikConnection
    
    Write-Verbose -Message 'Determining which version of the API to use'
    $resources = GetRubrikAPIData -endpoint ('SLADomainAssignPost')
    
    Write-Verbose -Message 'Determining the SLA Domain id'
    if ($SLA) 
    {
      $slaid = (Get-RubrikSLA -SLA $SLA).id
    }
    if ($Inherit) 
    {
      $slaid = 'INHERIT'
    }
    if ($DoNotProtect) 
    {
      $slaid = 'UNPROTECTED'
    }
    
    Write-Verbose -Message 'Building the URI'
    $uri = 'https://'+$Server+$resources.$api.URI
    # Replace the placeholder of {id} with the actual VM ID
    $uri = $uri -replace '{id}', $slaid
    
    # Set the method
    $method = $resources.$api.Method

    Write-Verbose -Message "Gathering managedId for $VM"
    [array]$vmids = (Get-RubrikVM -VM $VM).managedId

    $body = @{
      $resources.$api.Body.managedIds = $vmids
    }

    try
    {
      if ($PSCmdlet.ShouldProcess($VM,"Assign $SLA SLA Domain"))
      {
        $r = Invoke-WebRequest -Uri $uri -Headers $Header -Method $method -Body (ConvertTo-Json -InputObject $body)
        if ($r.StatusCode -ne $resources.$api.SuccessCode) 
        {
          Write-Warning -Message 'Did not receive successful status code from Rubrik for Live Mount request'
          throw $_
        }
        $response = ConvertFrom-Json -InputObject $r.Content
        
        # Sync jobs do not respond
        if ($response)
        {
          return $response.statuses
        }
      }
    }
    catch
    {
      throw $_
    }

  } # End of process
} # End of function
