# Import
Import-Module -Name "$PSScriptRoot\..\Rubrik" -Force
. "$(Split-Path -Parent -Path $PSScriptRoot)\Rubrik\Private\Get-RubrikAPIData.ps1"
$resources = GetRubrikAPIData -endpoint ('ReportBackupJobsDetailGet')

# Begin Pester tests
Describe -Name 'New-RubrikReport Tests' -Fixture {
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
        It -name 'Report Request' -test {
          # Arrange    
          Mock -CommandName Invoke-WebRequest -Verifiable -MockWith {
            return @{
              Content    = $resources.$api.SuccessMock
              StatusCode = $resources.$api.SuccessCode
            }
          } `
          -ModuleName Rubrik
    
          # Act
          $value1 = (ConvertFrom-Json -InputObject $resources.$api.SuccessMock).data.status
          (New-RubrikReport -ReportType daily -StatusType Failed -api $api).status | Should BeExactly $value1
    
          # Assert
          Assert-VerifiableMocks
        }
      }
    }
  }
} 