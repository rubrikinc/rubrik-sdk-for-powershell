# Import
Import-Module -Name "$PSScriptRoot\..\Rubrik" -Force
. "$(Split-Path -Parent -Path $PSScriptRoot)\Rubrik\Private\Get-RubrikAPIData.ps1"
$resources = GetRubrikAPIData -endpoint ('VMwareVMSnapshotGet')

# Pester

Describe -Name 'Get-RubrikSnapshot Tests' -Fixture {
  # set the API to v1
  $api = 'v1'

  It -name 'Ensure that Resources are loaded' -test {
    $resources | Should Not BeNullOrEmpty
  }

  It -name "[$api] Get VMware Snapshots" -test {
    # Arrange    
    Mock -CommandName Invoke-WebRequest -Verifiable -MockWith {
      return @{
        Content    = $resources.$api.SuccessMock
        StatusCode = $resources.$api.SuccessCode
      }
    } `
    -ModuleName Rubrik
    
    Mock -CommandName Get-RubrikVM -Verifiable -MockWith {
      return @{
        id = '11111111-2222-3333-4444-555555555555-vm-666666'
      }
    } `
    -ModuleName Rubrik
    
    # Act
    (Get-RubrikSnapshot -VM 'TEST1' -api $api).Count | Should BeExactly 2
    (Get-RubrikSnapshot -VM 'TEST1' -api $api).virtualMachineName | Should BeExactly 'TEST1'
    
    # Assert
    Assert-VerifiableMocks
  }
}