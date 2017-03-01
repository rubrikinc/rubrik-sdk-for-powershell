#Requires -Version 3
function Remove-RubrikSLA 
{
  <#  
      .SYNOPSIS
      Connects to Rubrik and removes SLA Domains
            
      .DESCRIPTION
      The Remove-RubrikSLA cmdlet will request that the Rubrik API delete an SLA Domain. The SLA Domain must have zero protected VMs in order to be successful.
            
      .NOTES
      Written by Chris Wahl for community usage
      Twitter: @ChrisWahl
      GitHub: chriswahl
            
      .LINK
      https://github.com/rubrikinc/PowerShell-Module
            
      .EXAMPLE
      Get-RubrikSLA -SLA 'Gold' | Remove-RubrikSLA
      This will attempt to remove the Gold SLA Domain from Rubrik if there are no VMs being protected by the policy
  #>

  [CmdletBinding(SupportsShouldProcess = $true,ConfirmImpact = 'High')]
  Param(
    # SLA Domain id
    [Parameter(Position = 0,ValueFromPipelineByPropertyName = $true)]
    [ValidateNotNullorEmpty()]
    [String]$id,
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
    $resources = Get-RubrikAPIData -endpoint ('SLADomainDelete')
  
  }

  Process {

    Write-Verbose -Message 'Build the URI'
    $uri = 'https://'+$Server+$resources.$api.URI
    # Replace the placeholder of {id} with the actual ID
    $uri = $uri -replace '{id}', $id
    
    Write-Verbose -Message 'Build the method'
    $method = $resources.$api.Method
        
    try 
    {
      if ($PSCmdlet.ShouldProcess($id,'Remove SLA Domain')) 
      {
        $r = Invoke-WebRequest -Uri $uri -Headers $header -Method $method
        if ($r.StatusCode -ne $resources.$api.SuccessCode) 
        {
          Write-Warning -Message 'Did not receive successful status code from Rubrik'
          throw $_
        }
        if ($r.Content) 
        {
          $response = ConvertFrom-Json -InputObject $r.Content
          return $response
        }
      }
    }
    catch 
    {
      throw $_
    }

  } # End of process
} # End of function