#Requires -Version 3
function Protect-RubrikVM
{
  <#
      .SYNOPSIS
      Connects to Rubrik and assigns an SLA to a virtual machine
            
      .DESCRIPTION
      The Protect-RubrikVM cmdlet will update a virtual machine's SLA Domain assignment within the Rubrik cluster.
      The SLA Domain contains all policy-driven values needed to protect workloads.
      Note that this function requires the virtual machine ID value, not the name of the virtual machine, since virtual machine names are not unique across clusters.
      It is suggested that you first use Get-RubrikVM to narrow down the one or more virtual machine to protect, and then pipe the results to Protect-RubrikVM.
      You will be asked to confirm each virtual machine you wish to protect, or you can use -Confirm:$False to skip confirmation checks.
            
      .NOTES
      Written by Chris Wahl for community usage
      Twitter: @ChrisWahl
      GitHub: chriswahl
            
      .LINK
      https://github.com/rubrikinc/PowerShell-Module
            
      .EXAMPLE
      Get-RubrikVM "VM1" | Protect-RubrikVM -SLA 'Gold'
      This will assign the Gold SLA Domain to any virtual machine named "VM1"

      .EXAMPLE
      Get-RubrikVM "VM1" -Filter ACTIVE -SLA Silver | Protect-RubrikVM -SLA 'Gold' -Confirm:$False
      This will assign the Gold SLA Domain to any virtual machine named "VM1" that is marked as ACTIVE and currently assigned to the Silver SLA Domain
      without asking for confirmation
  #>

  [CmdletBinding(SupportsShouldProcess = $true,ConfirmImpact = 'High')]
  Param(
    # Virtual machine name
    [Parameter(Mandatory = $true,Position = 0,ValueFromPipelineByPropertyName = $true)]
    [Alias('id')]
    [ValidateNotNullorEmpty()]
    [String]$VMID,
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

  Begin {

    Test-RubrikConnection
        
    Write-Verbose -Message 'Gather API data'
    $resources = Get-RubrikAPIData -endpoint ('VMwareVMPatch')
  
  }

  Process {
    
    $slaid = Test-RubrikSLA -SLA $SLA -Inherit $Inherit -DoNotProtect $DoNotProtect
    
    Write-Verbose -Message 'Build the URI'
    $uri = 'https://'+$Server+$resources.$api.URI
    # Replace the placeholder of {id} with the actual database ID
    $uri = $uri -replace '{id}', $VMID
    
    Write-Verbose -Message 'Build the method'
    $method = $resources.$api.Method
    
    Write-Verbose -Message 'Build the body'
    $body = @{}
    $body.Add($resources.$api.Body.SLA,$slaid)

    try
    {
      if ($PSCmdlet.ShouldProcess((Get-RubrikVM -id $VMID).name,"Assign SLA Domain $SLA"))
      {
        $r = Invoke-WebRequest -Uri $uri -Headers $Header -Method $method -Body (ConvertTo-Json -InputObject $body)
        if ($r.StatusCode -ne $resources.$api.SuccessCode) 
        {
          Write-Warning -Message 'Did not receive successful status code from Rubrik'
          throw $_
        }
        $return = ConvertFrom-Json -InputObject $r.Content       
      }
    }
    catch
    {
      throw $_
    }
    
    return $return

  } # End of process
} # End of function
