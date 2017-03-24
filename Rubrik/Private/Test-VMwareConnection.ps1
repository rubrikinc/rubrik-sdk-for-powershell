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
