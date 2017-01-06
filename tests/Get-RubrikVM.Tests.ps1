# Import
Import-Module -Name "$PSScriptRoot\..\Rubrik" -Force
. "$(Split-Path -Parent -Path $PSScriptRoot)\Rubrik\Private\Get-RubrikAPIData.ps1"
$resources = GetRubrikAPIData -endpoint ('VMwareVMGet')

# Begin Pester tests
Describe -Name 'Get-RubrikVM Tests' -Fixture {
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
        It -name 'All VMs' -test {
          # Arrange
          Mock -CommandName Invoke-WebRequest -Verifiable -MockWith {
            return @{
              Content    = $resources.$api.SuccessMock
              StatusCode = $resources.$api.SuccessCode
            }
          } `
          -ModuleName Rubrik
    
          # Act
          (Get-RubrikVM -api $api).count | Should BeExactly 2    
    
          # Assert
          Assert-VerifiableMocks
        }
  
        It -name 'Name and Filter Queries' -test {
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
              $value1 = (ConvertFrom-Json -InputObject $resources.$api.SuccessMock)[0].name
              $value2 = 'RELIC'
              $value3 = (ConvertFrom-Json -InputObject $resources.$api.SuccessMock)[0].effectiveSlaDomainName
            }
            default 
            {
              $value1 = (ConvertFrom-Json -InputObject $resources.$api.SuccessMock).data[0].name
              $value2 = 'RELIC'
              $value3 = (ConvertFrom-Json -InputObject $resources.$api.SuccessMock).data[0].effectiveSlaDomainName
            }
          }
          (Get-RubrikVM -VM $value1 -Filter $value2 -SLA $value3 -api $api).name | Should BeExactly $value1
    
          # Assert
          Assert-VerifiableMocks
        }
  
        It -name 'Specific SLA' -test {
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
              $value1 = (ConvertFrom-Json -InputObject $resources.$api.SuccessMock)[1].name
            }
            default 
            {
              $value1 = (ConvertFrom-Json -InputObject $resources.$api.SuccessMock).data[1].name
            }
          }
          
          (Get-RubrikVM -SLA Unprotected -api $api).name | Should BeExactly $value1
    
          # Assert
          Assert-VerifiableMocks
        }
      }
    }
  }
}