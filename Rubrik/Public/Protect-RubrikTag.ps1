#Requires -Version 3

function Protect-RubrikTag
{
  <#
      .SYNOPSIS
      Connects to Rubrik and assigns an SLA Domain based on a vSphere category and tag value

      .DESCRIPTION
      The Protect-RubrikTag cmdlet will update a virtual machine's SLA Domain assignment within the Rubrik cluster.
      The SLA Domain contains all policy-driven values needed to protect workloads.
      Make sure you have PowerCLI installed and connect to the required vCenter Server.

      .NOTES
      Written by Jason Burrell for community usage
      Twitter: @jasonburrell2

      .LINK
      https://github.com/rubrikinc/PowerShell-Module

      .EXAMPLE
      Protect-RubrikTag -Tag 'Gold' -Category 'Rubrik'
      This will assign the Gold SLA Domain to any VM tagged with Gold in the Rubrik category

      .EXAMPLE
      Protect-RubrikTag -Tag 'Gold' -Category 'Rubrik' -SLA 'Titanium'
      This will assign the Titanium SLA Domain to any VM tagged with Gold in the Rubrik category
  #>

  [CmdletBinding(SupportsShouldProcess = $true,ConfirmImpact = 'High')]
  Param(
    # vSphere Tag
    [Parameter(Mandatory = $true,Position = 0)]
    [ValidateNotNullorEmpty()]
    [String]$Tag,
    # vSphere Tag Category
    [Parameter(Mandatory = $true,Position = 1)]
    [ValidateNotNullorEmpty()]
    [String]$Category,
    # Rubrik SLA Domain
    [Parameter(Position = 2)]
    [ValidateNotNullorEmpty()]
    [String]$SLA,
    # Rubrik server IP or FQDN
    [Parameter(Position = 3)]
    [String]$Server = $global:RubrikConnection.server,
    # API version
    [Parameter(Position = 4)]
    [String]$api = $global:RubrikConnection.api
  )

  Begin {

    Test-RubrikConnection
        
    Write-Verbose -Message 'Gather API data'
    $resources = Get-RubrikAPIData -endpoint ('SLADomainAssignPost')
  
  }

  Process {

    Test-VMwareConnection

    Write-Verbose -Message 'Gathering the SLA Domain id'
    try 
    {
      if ($SLA) 
      {
        Write-Verbose -Message 'Using explicit SLA request from input'
        $slaid = (Get-RubrikSLA -SLA $SLA).id
      }
      else 
      {
        Write-Verbose -Message 'No explicit SLA requested; deferring to Tag name'
        $slaid = (Get-RubrikSLA -SLA $Tag).id
      }
    }
    catch
    {
      throw $_
    }

    Write-Verbose -Message "Gathering a list of VMs associated with Category $Category and Tag $Tag"
    try 
    {
      $vmlist = Get-VM -Tag (Get-Tag -Name $Tag -Category $Category) | Get-View
      # This will pull out the vCenter UUID assigned to the parent vCenter Server by Rubrik
      $vcuuid = (Get-RubrikVM -VM $vmlist[0].Name).vCenterId
    }
    catch
    {
      throw $_
    }

    Write-Verbose -Message 'Building an array of Rubrik Managed IDs'
    [array]$vmbulk = @()
    foreach ($_ in $vmlist)
    {
      $vmbulk += 'VirtualMachine:::' + $vcuuid + '-' + $($_.moref.value)
      Write-Verbose -Message "Found $($vmbulk.count) records"
    }

    Write-Verbose -Message 'Creating the array to mass assign the list of IDs'
    $body = @{
      managedIds = $vmbulk
    }
        
    Write-Verbose -Message 'Build the URI'
    $uri = 'https://'+$Server+$resources.$api.URI
    # Replace the placeholder of {id} with the actual VM ID
    $uri = $uri -replace '{id}', $slaid
    
    Write-Verbose -Message 'Build the method'
    $method = $resources.$api.Method

    Write-Verbose -Message 'Submit the request'
    try 
    {
      if ($PSCmdlet.ShouldProcess("$($vmbulk.count) $Tag tagged object(s)","Assign $($slaid.name) SLA Domain"))
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
