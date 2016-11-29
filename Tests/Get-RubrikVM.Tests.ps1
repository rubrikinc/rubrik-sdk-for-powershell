# Import
Import-Module -Name "$PSScriptRoot\..\Rubrik" -Force
. "$(Split-Path -Parent -Path $PSScriptRoot)\Rubrik\Private\Get-RubrikAPIData.ps1"
$resources = GetRubrikAPIData -endpoint ('VMwareVMGet')

# Pester

Describe -Name 'Get-RubrikVM Tests' -Fixture {
  # set the API to v1
  $api = 'v1'

  It -name 'Ensure that Resources are loaded' -test {
    $resources | Should Not BeNullOrEmpty
  }

  It -name "[$api] Get VMware VMs - All" -test {
    # Arrange    
    Mock -CommandName Invoke-WebRequest -Verifiable -MockWith {
      return @{
        Content    = $resources.$api.SuccessMock
        StatusCode = $resources.$api.SuccessCode
      }
    } `
    -ModuleName Rubrik
    
    # Act
    $value = Get-RubrikVM -api $api
    $value.count | Should BeExactly 2    
    
    # Assert
    Assert-VerifiableMocks
  }
  
  # Find the VM named "TEST1" - Relic, No SLA
  It -name "[$api] Get VMware VMs - Name and Filter Queries" -test {
    # Arrange    
    Mock -CommandName Invoke-WebRequest -Verifiable -MockWith {
      return @{
        Content    = $resources.$api.SuccessMock
        StatusCode = $resources.$api.SuccessCode
      }
    } `
    -ModuleName Rubrik
    
    # Act
    $value = Get-RubrikVM -VM 'TEST1' -Filter RELIC -SLA Gold -api $api
    $value.name | Should BeExactly 'TEST1'
    
    # Assert
    Assert-VerifiableMocks
  }
  
  # Find the VM named "Test2" - Unprotected SLA
  It -name "[$api] Get VMware VMs - Specific SLA" -test {
    # Arrange    
    Mock -CommandName Invoke-WebRequest -Verifiable -MockWith {
      return @{
        Content    = $resources.$api.SuccessMock
        StatusCode = $resources.$api.SuccessCode
      }
    } `
    -ModuleName Rubrik
    
    # Act
    $value = Get-RubrikVM -SLA Unprotected -api $api
    $value.name | Should BeExactly 'TEST2'
    
    # Assert
    Assert-VerifiableMocks
  }
}