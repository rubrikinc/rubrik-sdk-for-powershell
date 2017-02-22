function Test-RubrikConnection() 
{
  # Test to see if a session has been established to the Rubrik cluster
  # If no token is found, this will throw an error and halt the script
  # Otherwise, the token is loaded into the script's $Header var
  
  Write-Verbose -Message 'Validating the Rubrik token exists'
  if (-not $global:RubrikConnection.token) 
  {
    throw 'You are not connected to a Rubrik server. Use Connect-Rubrik.'
  }
  Write-Verbose -Message 'Found a Rubrik token for authentication'
  $script:Header = $global:RubrikConnection.header
}

function Test-VMwareConnection($vCenter)
{
  # Import all of the VMware Modules and then test to see if a vCenter connection exists
  # Will throw an error and ask the user to connect if no session is found

  Write-Verbose -Message 'Import required modules'
  try 
  {
    Get-Module -ListAvailable -Name 'VMware*' | Import-Module -ErrorAction Stop
  }
  catch 
  {
    Write-Warning -Message 'PowerCLI version 6 or later required.'
    Write-Warning -Message 'Visit: http://www.vmware.com/go/powercli'
    throw $_
  }

  Write-Verbose -Message 'Ignore self-signed SSL certificates for vCenter Server'
  $null = Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -DisplayDeprecationWarnings:$false -Scope User -Confirm:$false
  
  if ($vCenter -eq $null -and $global:DefaultVIServer -ne $null) 
  {
    $vCenter = $global:DefaultVIServer.Name
  }
  else 
  {
    throw 'You are not connected to a vCenter Server'
  }

  Write-Verbose -Message 'Connect to vCenter'
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
