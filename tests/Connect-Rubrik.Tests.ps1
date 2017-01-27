# Import
Import-Module -Name "$PSScriptRoot\..\Rubrik" -Force
. "$(Split-Path -Parent -Path $PSScriptRoot)\Rubrik\Private\Get-RubrikAPIData.ps1"
$resources = GetRubrikAPIData -endpoint ('Session')

# Pester

Describe -Name 'Connect-Rubrik Tests' -Fixture {
  It -name 'Ensure that Resources are loaded' -test {
    $resources | Should Not BeNullOrEmpty
  }

  foreach ($api in $resources.Keys | Sort-Object -Descending)
  {
    if ($resources.$api.SuccessMock) 
    {
      Context -Name "set to API $api" -Fixture {
        It -name 'Valid credentials' -test {
          # Arrange
          Mock -CommandName Invoke-WebRequest -Verifiable -MockWith {
            return @{
              Content    = $resources.'v1.1'.SuccessMock
              StatusCode = $resources.'v1.1'.SuccessCode
            }
          } -ModuleName Rubrik
    
          # Act
          Connect-Rubrik -Server '1.2.3.4' -Username test -Password ('test' | ConvertTo-SecureString -AsPlainText -Force)
          $rubrikConnection.token | Should Be (ConvertFrom-Json -InputObject $resources.$api.SuccessMock).token
    
          # Assert
          Assert-VerifiableMocks
        }
  
        It -name 'Invalid credentials' -test {
          # Arrange    
          Mock -CommandName Invoke-WebRequest -Verifiable -MockWith {
            return @{
              Content    = $resources.$api.FailureMock
              StatusCode = $resources.$api.FailureCode
            }
          } -ModuleName Rubrik
    
          # Act
          try 
          {
            Connect-Rubrik -Server '1.2.3.4' -Username test -Password ('test' | ConvertTo-SecureString -AsPlainText -Force)
          }
          catch 
          {
            $_ | Should Be 'Unable to connect with any available API version'
          }
    
          # Assert
          Assert-VerifiableMocks
        }
      }
    }
  }
}