# Import
Import-Module -Name "$PSScriptRoot\..\Rubrik" -Force
. "$(Split-Path -Parent -Path $PSScriptRoot)\Rubrik\Private\Get-RubrikAPIData.ps1"
$resources = Get-RubrikAPIData -endpoint ('SLADomainGet')

# Begin Pester tests
Describe -Name 'Get-RubrikSLA Tests' -Fixture {
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
        It -name 'Count SLA Domains' -test {
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
          (Get-RubrikSLA -api $api).Count | Should BeExactly $value1
    
          # Assert
          Assert-VerifiableMocks
        }
        
        It -name 'Retrieve SLA Domain ID' -test {
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
              $value2 = (ConvertFrom-Json -InputObject $resources.$api.SuccessMock)[0].id
            }
            default 
            {
              $value1 = (ConvertFrom-Json -InputObject $resources.$api.SuccessMock).data[0].name
              $value2 = (ConvertFrom-Json -InputObject $resources.$api.SuccessMock).data[0].id
            }
          }
          (Get-RubrikSLA -SLA $value1 -api $api).Id | Should BeExactly $value2
    
          # Assert
          Assert-VerifiableMocks
        }
        
        
        It -name 'Retrieve Quantity of VMs Protected' -test {
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
              $value2 = (ConvertFrom-Json -InputObject $resources.$api.SuccessMock)[1].numVms
            }
            default 
            {
              $value1 = (ConvertFrom-Json -InputObject $resources.$api.SuccessMock).data[1].name
              $value2 = (ConvertFrom-Json -InputObject $resources.$api.SuccessMock).data[1].numVms
            }
          }

          (Get-RubrikSLA -SLA $value1 -api $api).numVms | Should BeExactly $value2
    
          # Assert
          Assert-VerifiableMocks
        }
      }
    }
  }
}

 