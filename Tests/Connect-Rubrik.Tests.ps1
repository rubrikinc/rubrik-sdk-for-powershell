# Import
Import-Module -Name "$PSScriptRoot\..\Rubrik" -Force
. "$(Split-Path -Parent -Path $PSScriptRoot)\Rubrik\Private\Get-RubrikAPIData.ps1"
$resources = GetRubrikAPIData -endpoint ('Login')

# Pester

Describe -Name 'Connect-Rubrik Tests' -Fixture {
  It -name 'Ensure that Resources are loaded' -test {
    $resources | Should Not BeNullOrEmpty
  }

  It -name '[v1] Valid credentials' -test {
    # Arrange    
    Mock -CommandName Invoke-WebRequest -Verifiable -MockWith {
      return @{
        Content    = $resources.v1.SuccessMock
        StatusCode = $resources.v1.SuccessCode
      }
    } `
    -ParameterFilter {
      $uri -match $resource.v1.URI
    } -ModuleName Rubrik
    
    # Act
    Connect-Rubrik -Server '1.2.3.4' -Username test -Password ('test' | ConvertTo-SecureString -AsPlainText -Force)
    $rubrikConnection.token | Should Be (ConvertFrom-Json -InputObject $resources.v1.SuccessMock).token
    
    # Assert
    Assert-VerifiableMocks
  }
  
  It -name '[v1] Invalid credentials' -test {
    # Arrange    
    Mock -CommandName Invoke-WebRequest -Verifiable -MockWith {
      return @{
        Content    = $resources.v1.FailureMock
        StatusCode = $resources.v1.FailureCode
      }
    } `
    -ParameterFilter {
      $uri -match $resources.v1.URI
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
  
  
  It -name '[v0] Valid credentials' -test {
    # Arrange    
    Mock -CommandName Invoke-WebRequest -Verifiable -MockWith {
      return @{
        Content    = $resources.v0.SuccessMock
        StatusCode = $resources.v0.SuccessCode
      }
    } `
    -ParameterFilter {
      $uri -notmatch $resources.v1.URI
    } -ModuleName Rubrik
    
    # Act
    Connect-Rubrik -Server '1.2.3.4' -Username test -Password ('test' | ConvertTo-SecureString -AsPlainText -Force)
    $rubrikConnection.token | Should Be (ConvertFrom-Json -InputObject $resources.v0.SuccessMock).token
    
    # Assert
    Assert-VerifiableMocks
  }
  
  It -name '[v0] Invalid credentials' -test {
    # Arrange    
    Mock -CommandName Invoke-WebRequest -Verifiable -MockWith {
      return @{
        Content    = $resources.v0.FailureMock
        StatusCode = $resources.v0.FailureCode
      }
    } `
    -ParameterFilter {
      $uri -notmatch $resources.v1.URI
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