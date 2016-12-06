# Import
Import-Module -Name "$PSScriptRoot\..\Rubrik" -Force
. "$(Split-Path -Parent -Path $PSScriptRoot)\Rubrik\Private\Get-RubrikAPIData.ps1"
$resources = GetRubrikAPIData -endpoint ('VMwareVMSnapshotGet')

# Begin Pester tests
Describe -Name 'Get-RubrikSnapshot Tests' -Fixture {
  # Test to make sure that resources were loaded
  It -name 'Ensure that Resources are loaded' -test {
    $resources | Should Not BeNullOrEmpty
  }

  # Set the API context and begin testing
  foreach ($api in $resources.Keys)
  {
    if ($resources.$api.SuccessMock) 
    {
      Context -Name "set to API $api" -Fixture {
        It -name 'Count VMware Snapshots' -test {
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
              id = (ConvertFrom-Json -InputObject $resources.v1.SuccessMock).data[0].id
            }
          } `
          -ModuleName Rubrik
    
          # Act
          Switch ($api) {
            'v0' 
            {
              $value1 = (ConvertFrom-Json -InputObject $resources.$api.SuccessMock)[0].virtualMachineName
              $value2 = 2
            }
            default 
            {
              $value1 = (ConvertFrom-Json -InputObject $resources.$api.SuccessMock).data[0].virtualMachineName
              $value2 = (ConvertFrom-Json -InputObject $resources.$api.SuccessMock).total
            }
          }
          (Get-RubrikSnapshot -VM $value1 -api $api).Count | Should BeExactly $value2
    
          # Assert
          Assert-VerifiableMocks
        }
        
        It -name 'Match Snapshot by Name' -test {
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
              id = (ConvertFrom-Json -InputObject $resources.v1.SuccessMock).data[0].id
            }
          } `
          -ModuleName Rubrik
    
          # Act
          Switch ($api) {
            'v0' 
            {
              $value1 = (ConvertFrom-Json -InputObject $resources.$api.SuccessMock)[0].virtualMachineName
            }
            default 
            {
              $value1 = (ConvertFrom-Json -InputObject $resources.$api.SuccessMock).data[0].virtualMachineName
            }
          }          
          (Get-RubrikSnapshot -VM $value1 -api $api).virtualMachineName | Should BeExactly $value1
    
          # Assert
          Assert-VerifiableMocks
        }
      }
    }
  }
}