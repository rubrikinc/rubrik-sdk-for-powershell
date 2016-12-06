# Import
Import-Module -Name "$PSScriptRoot\..\Rubrik" -Force
. "$(Split-Path -Parent -Path $PSScriptRoot)\Rubrik\Private\Get-RubrikAPIData.ps1"
$resources = GetRubrikAPIData -endpoint ('VMwareVMMountGet')

# Pester

Describe -Name 'Get-RubrikMount Tests' -Fixture {
  # set the API to v1
  $api = 'v1'

  It -name 'Ensure that Resources are loaded' -test {
    $resources | Should Not BeNullOrEmpty
  }

  It -name "[$api] Get VMware Mounts" -test {
    # Arrange    
    Mock -CommandName Invoke-WebRequest -Verifiable -MockWith {
      return @{
        Content    = $resources.$api.SuccessMock
        StatusCode = $resources.$api.SuccessCode
      }
    } `
    -ModuleName Rubrik
    
    # Act
    (Get-RubrikMount -api $api).Count | Should BeExactly 2
    (Get-RubrikMount -VM 'TEST1' -api $api).sourceVirtualMachineId | Should BeExactly "aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee-vm-fff"
    (Get-RubrikMount -MountID "aaaaaaaa-2222-3333-4444-555555555555" -api $api).sourceVirtualMachineName | Should BeExactly "TEST2"
    
    # Assert
    Assert-VerifiableMocks
  }

  # set the API to v1
  $api = 'v0'
  
    It -name "[$api] Get VMware Mounts" -test {
    # Arrange    
    Mock -CommandName Invoke-WebRequest -Verifiable -MockWith {
      return @{
        Content    = $resources.$api.SuccessMock
        StatusCode = $resources.$api.SuccessCode
      }
    } `
    -ModuleName Rubrik
    
    # Act
    (Get-RubrikMount -api $api).Count | Should BeExactly 2
    (Get-RubrikMount -VM 'TEST1' -api $api).sourceVirtualMachineId | Should BeExactly "aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee-vm-fff"
    (Get-RubrikMount -MountID "aaaaaaaa-2222-3333-4444-555555555555" -api $api).sourceVirtualMachineName | Should BeExactly "TEST2"
    
    # Assert
    Assert-VerifiableMocks
  }
}