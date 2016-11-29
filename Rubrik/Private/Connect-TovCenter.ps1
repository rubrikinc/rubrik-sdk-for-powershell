<#
    Helper function to connect to a vCenter Server and allows self-signed certificates for vCenter connections
#>
function ConnectTovCenter($vCenter) 
{
  Write-Verbose -Message 'Importing required modules'
  try 
  {
    Import-Module -Name VMware.VimAutomation.Core -ErrorAction Stop
  }
  catch 
  {
    Write-Warning -Message 'PowerCLI version 6 or later required.'
    Write-Warning -Message 'Visit: http://www.vmware.com/go/powercli'
    throw $_
  }

  Write-Verbose -Message 'Ignoring self-signed SSL certificates for vCenter Server (optional)'
  $null = Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -DisplayDeprecationWarnings:$false -Scope User -Confirm:$false

  Write-Verbose -Message 'Connecting to vCenter'
  try 
  {
    $null = Connect-VIServer -Server $vCenter -ErrorAction Stop -Session ($global:DefaultVIServers | Where-Object -FilterScript {
        $_.name -eq $vCenter
    }).sessionId
  }
  catch 
  {
    throw $_
  }
}
