# Import
Import-Module -Name "$PSScriptRoot\..\Rubrik" -Force
. "$(Split-Path -Parent -Path $PSScriptRoot)\Rubrik\Private\Get-RubrikAPIData.ps1"
$resources = GetRubrikAPIData -endpoint ('VMwareVM')

# Pester

Describe -Name 'Get-RubrikVM Tests' -Fixture {
  It -name 'Ensure that Resources are loaded' -test {
    $resources | Should Not BeNullOrEmpty
  }

  It -name '[v1] Get VMware VMs - All' -test {
    # Arrange    
    Mock -CommandName Invoke-WebRequest -Verifiable -MockWith {
      return @{
        Content    = $resources.v1.SuccessMock
        StatusCode = $resources.v1.SuccessCode
      }
    } `
    -ModuleName Rubrik
    
    # Act
    $value = Get-RubrikVM
    $value.count | Should BeExactly 2
    
    
    # Assert
    Assert-VerifiableMocks
  }
  
  # Find the VM named "Test1" - Relic, No SLA
  #It -name '[v1] Get VMware VMs - Name and Filter Queries'
  
  # Find the VM named "Test2" - Active, Gold SLA
  #It -name '[v1] Get VMware VMs - Specific SLA'
  
 
}