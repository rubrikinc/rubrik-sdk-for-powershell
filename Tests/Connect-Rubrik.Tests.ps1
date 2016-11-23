# Import
Import-Module -Name "$PSScriptRoot\..\Rubrik" -Force

# Pester

Describe -Name 'Connect-Rubrik Tests' -Fixture {
  # Setup
  $resources = GetRubrikAPIData -endpoint ('Login')

  It -name 'Valid credentials to the v1 API' -test {
    # Arrange    
    Mock -CommandName Invoke-WebRequest -Verifiable -MockWith {
      return @{
        Content    = $resources[1].SuccessMock
        StatusCode = $resources[1].SuccessCode
      }
    } `
    -ParameterFilter {
      $uri -match $resources[1].URI
    }
    
    # Act
    Connect-Rubrik -Server '1.2.3.4' -Username test -Password ('test' | ConvertTo-SecureString -AsPlainText -Force)
    $rubrikConnection.token | Should Be (ConvertFrom-Json -InputObject $resources[1].SuccessMock).token
    
    # Assert
    Assert-VerifiableMocks
  }
  
  It -name 'Invalid credentials to the v1 API' -test {
    # Arrange    
    Mock -CommandName Invoke-WebRequest -Verifiable -MockWith {
      return @{
        Content    = $resources[1].FailureMock
        StatusCode = $resources[1].FailureCode
      }
    } `
    -ParameterFilter {
      $uri -match $resources[1].URI
    }
    
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
  
  
  It -name 'Valid credentials to the v0 API' -test {
    # Arrange    
    Mock -CommandName Invoke-WebRequest -Verifiable -MockWith {
      return @{
        Content    = $resources[0].SuccessMock
        StatusCode = $resources[0].SuccessCode
      }
    } `
    -ParameterFilter {
      $uri -notmatch $resources[1].URI
    }
    
    # Act
    Connect-Rubrik -Server '1.2.3.4' -Username test -Password ('test' | ConvertTo-SecureString -AsPlainText -Force)
    $rubrikConnection.token | Should Be (ConvertFrom-Json -InputObject $resources[0].SuccessMock).token
    
    # Assert
    Assert-VerifiableMocks
  }
  
  It -name 'Invalid credentials to the v0 API' -test {
    # Arrange    
    Mock -CommandName Invoke-WebRequest -Verifiable -MockWith {
      return @{
        Content    = $resources[0].FailureMock
        StatusCode = $resources[0].FailureCode
      }
    } `
    -ParameterFilter {
      $uri -notmatch $resources[1].URI
    }
    
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