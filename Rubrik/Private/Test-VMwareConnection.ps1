function Test-VMwareConnection() {
  <#
    .SYNOPSIS
    Tests connection status to VMware vCenter

    .DESCRIPTION
    The Test-VMwareConnection function tests to see if both the PowerCLI module has been installed and loaded, and that a connection has been established to only one vCenter Server.
    Must have only one vCenter connection open
    Potential future work: loop through all vCenter connections
    Code snipet blatantly stolen from Vester :)
  #>

  if ((Get-Module -ListAvailable -Name VMware.PowerCLI) -eq $null) {
    Write-Warning -Message 'Please install VMware PowerCli PowerShell module before running this command.'
    throw 'VMware.PowerCli module is required.'
  }
  ElseIf ($DefaultVIServers.Count -lt 1) {
    Write-Warning -Message 'Please connect to vCenter before running this command.'
    throw 'A single connection with Connect-VIServer is required.'
  }
  ElseIf ($DefaultVIServers.Count -gt 1) {
    Write-Warning -Message 'Please connect to only one vCenter before running this command.'
    Write-Warning -Message "Current connections:  $($DefaultVIServers -join ' / ')"
    throw 'A single connection with Connect-VIServer is required.'
  }
  Write-Verbose -Message "vCenter: $($DefaultVIServers.Name)"
}
