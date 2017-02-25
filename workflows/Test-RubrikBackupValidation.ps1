#Requires -Version 3 -Module Pester,VMware.VimAutomation.Core,Rubrik

<#

  .SYNOPSIS
  Backup Validation Sample Workflow

  .DESCRIPTION
  Based on a Webinar named "Automatically Ensure your Applications, Services, and Servers can be Restored"
  This is just meant as a sample set of Pester tests to build a backup validation workflow
  Use these ideas to build your own workflows for instantiating, testing, and validating snapshots on Rubrik

  .NOTES
  Written by Chris Wahl for community usage
  Twitter: @ChrisWahl
  GitHub: chriswahl

  .LINK
  http://pages.rubrik.com/20170126-Webinar-RESTfulAPIIntro_Reg.html

  .LINK
  https://www.rubrik.com/automation-to-validate-in-rubrik-backups/
        
  .EXAMPLE
  Here are the values I used in the webinar based on my lab environment
  Adjust for your own environment and enjoy! :)

  $Rubrik           = '172.17.28.18'
  $vCenter          = '172.17.48.22'
  $VM               = 'SE-CWAHL-WIN'
  $MountName        = 'Sandbox1'
  $SandboxNetwork   = 'VLAN50_SERVERS_MOUNT'
  $SandboxIPAddress = '172.17.50.111'
  $SandboxGateway   = '172.17.50.1'
  $GuestCred        = Get-Credential -Message 'Guest Credentials'
  $RubrikCred       = Get-Credential -Message 'Rubrik Credentials'
  $vCenterCred      = Get-Credential -Message 'vCenter Credentials'

#>

Describe -Name 'Establish Connectivity' -Fixture {
  # Connect to Rubrik
  It -name 'Connect to Rubrik Cluster' -test {
    Connect-Rubrik -Server $Rubrik -Credential $RubrikCred
    $rubrikConnection.token | Should Be $true
  }
  # Connect to vCenter
  It -name 'Connect to vCenter Server' -test {
    Connect-VIServer -Server $vCenter -Credential $vCenterCred
    $global:DefaultVIServer.SessionId | Should Be $true
  }
}

Describe -Name 'Create Live Mount for Sandbox' -Fixture {
  # Spin up Live Mount
  It -name 'Request Live Mount' -test {
    (New-RubrikMount -VM $VM -MountName $MountName -PowerOn).requestId | Should Be $true
    Start-Sleep -Seconds 1
  }
  # Wait for Live Mount to become available in vSphere
  It -name 'Verify Live Mount is Powered On' -test {
    while ((Get-VM -Name $MountName -ErrorAction:SilentlyContinue).PowerState -ne 'PoweredOn') 
    {
      Start-Sleep -Seconds 1
    }
    (Get-VM -Name $MountName).PowerState | Should Be 'PoweredOn'
  }
  # Wait for VMware Tools to Start
  It -name 'Verify VMware Tools are Running' -test {
    while ((Get-VM $MountName).ExtensionData.Guest.ToolsRunningStatus -ne 'guestToolsRunning') 
    {
      Start-Sleep -Seconds 1
    }
    (Get-VM $MountName).ExtensionData.Guest.ToolsRunningStatus | Should Be 'guestToolsRunning'
  }
  # Connect Live Mount to Sandbox Network
  It -name 'Move vNIC to Sandbox Network' -test {
    (Get-NetworkAdapter -VM $MountName | Set-NetworkAdapter -NetworkName $SandboxNetwork -Connected:$true -Confirm:$false).NetworkName | Should Be $SandboxNetwork
  }  
  # Set the IP
  It -name "Set Adapter IP Address to $SandboxIPAddress" -test {
    $splat = @{
      ScriptText      = 'Get-NetAdapter | where {$_.Status -eq "Up"} | New-NetIPAddress -IPAddress '+$SandboxIPAddress+" -PrefixLength 24 -DefaultGateway $SandboxGateway"
      ScriptType      = 'PowerShell'
      VM              = $MountName
      GuestCredential = $GuestCred
    }
    Invoke-VMScript @splat
  }
}
    
Describe -Name 'Sandbox Tests' -Fixture {
  # Make sure VM is alive
  It -name 'Test 1 - Network Responds to Ping' -test {
    Test-Connection -ComputerName $SandboxIPAddress -Quiet | Should Be 'True'
  }
  
  # Perform tests against Live Mount
  It -name 'Test 2 - Netlogon Service is Running' -test {
    $GuestCredAlt = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList ('.\'+$GuestCred.UserName), ($GuestCred.Password)
    (Get-WmiObject -Class Win32_Service -ComputerName $SandboxIPAddress -Credential $GuestCredAlt -Filter "name='Netlogon'").State | Should Be 'Running'
  }
  
  <# SAMPLE for SQL Server
      # Perform tests against SQL Server
      It -name 'Test 3 - Primary SQL Server Instance is Listening' -test {
      (Test-NetConnection -ComputerName $SandboxIPAddress -Port 1433).TcpTestSucceeded | Should Be $true
      }
  #>
}