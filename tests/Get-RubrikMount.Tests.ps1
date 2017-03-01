# Import
Import-Module -Name "$PSScriptRoot\..\Rubrik" -Force
. "$(Split-Path -Parent -Path $PSScriptRoot)\Rubrik\Private\Get-RubrikAPIData.ps1"
$resources = Get-RubrikAPIData -endpoint ('VMwareVMMountGet')

# Begin Pester tests
Describe -Name 'Get-RubrikMount Tests' -Fixture {
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
        It -name 'Count VMware Mounts' -test {
          # Arrange    
          Mock -CommandName Invoke-WebRequest -Verifiable -MockWith {
            return @{
              Content    = $resources.$api.SuccessMock
              StatusCode = $resources.$api.SuccessCode
            }
          } `
          -ModuleName Rubrik
    
          # Act
          Switch ($api) {
            'v0' 
            {
              $value1 = 2
            }
            default 
            {
              $value1 = (ConvertFrom-Json -InputObject $resources.$api.SuccessMock).total
            }
          }
          (Get-RubrikMount -api $api).Count | Should BeExactly $value1
    
          # Assert
          Assert-VerifiableMocks
        }
        
        It -name 'Supply VM Name, Retrieve VM ID' -test {
          # Arrange    
          Mock -CommandName Invoke-WebRequest -Verifiable -MockWith {
            return @{
              Content    = $resources.$api.SuccessMock
              StatusCode = $resources.$api.SuccessCode
            }
          } `
          -ModuleName Rubrik
    
          # Act
          Switch ($api) {
            'v0' 
            {
              $value1 = (ConvertFrom-Json -InputObject $resources.$api.SuccessMock)[0].sourceVirtualMachineName
              $value2 = (ConvertFrom-Json -InputObject $resources.$api.SuccessMock)[0].sourceVirtualMachineId
            }
            default 
            {
              $value1 = (ConvertFrom-Json -InputObject $resources.$api.SuccessMock).data[0].sourceVirtualMachineName
              $value2 = (ConvertFrom-Json -InputObject $resources.$api.SuccessMock).data[0].sourceVirtualMachineId
            }
          }
          (Get-RubrikMount -VM $value1 -api $api).sourceVirtualMachineId | Should BeExactly $value2
    
          # Assert
          Assert-VerifiableMocks
        }
        
        
        It -name 'Supply Mount ID, Retrieve VM Name' -test {
          # Arrange    
          Mock -CommandName Invoke-WebRequest -Verifiable -MockWith {
            return @{
              Content    = $resources.$api.SuccessMock
              StatusCode = $resources.$api.SuccessCode
            }
          } `
          -ModuleName Rubrik
    
          # Act
          Switch ($api) {
            'v0' 
            {
              $value1 = (ConvertFrom-Json -InputObject $resources.$api.SuccessMock)[1].Id
              $value2 = (ConvertFrom-Json -InputObject $resources.$api.SuccessMock)[1].sourceVirtualMachineName
            }
            default 
            {
              $value1 = (ConvertFrom-Json -InputObject $resources.$api.SuccessMock).data[1].Id
              $value2 = (ConvertFrom-Json -InputObject $resources.$api.SuccessMock).data[1].sourceVirtualMachineName
            }
          }

          (Get-RubrikMount -MountID $value1 -api $api).sourceVirtualMachineName | Should BeExactly $value2
    
          # Assert
          Assert-VerifiableMocks
        }
      }
    }
  }
}

 