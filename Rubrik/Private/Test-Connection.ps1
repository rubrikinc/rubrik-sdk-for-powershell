function Test-RubrikConnection() 
{
  # Test to see if a session has been established to the Rubrik cluster
  # If no token is found, this will throw an error and halt the script
  # Otherwise, the token is loaded into the script's $Header var
  
  Write-Verbose -Message 'Validating the Rubrik token exists'
  if (-not $global:RubrikConnection.token) 
  {
    Write-Warning -Message 'Please connect to only one Rubrik Cluster before running this command.'
    throw 'A single connection with Connect-Rubrik is required.'
  }
  Write-Verbose -Message 'Found a Rubrik token for authentication'
  $script:Header = $global:RubrikConnection.header
}

function Test-VMwareConnection()
{
  # Must have only one vCenter connection open
  # Potential future work: loop through all vCenter connections
  # Code snipet blatantly stolen from Vester :)

  If ($DefaultVIServers.Count -lt 1) 
  {
    Write-Warning -Message 'Please connect to vCenter before running this command.'
    throw 'A single connection with Connect-VIServer is required.'
  }
  ElseIf ($DefaultVIServers.Count -gt 1) 
  {
    Write-Warning -Message 'Please connect to only one vCenter before running this command.'
    Write-Warning -Message "Current connections:  $($DefaultVIServers -join ' / ')"
    throw 'A single connection with Connect-VIServer is required.'
  }
  Write-Verbose -Message "vCenter: $($DefaultVIServers.Name)"
}
