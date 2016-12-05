# Import
Import-Module -Name "$PSScriptRoot\..\Rubrik" -Force
. "$(Split-Path -Parent -Path $PSScriptRoot)\Rubrik\Private\Get-RubrikAPIData.ps1"
$resources = GetRubrikAPIData -endpoint ('VMwareVMMountPost')

# Pester

Describe -Name 'New-RubrikMount Tests' -Fixture {
  # set the API to v1
  $api = 'v1'

  It -name 'Ensure that Resources are loaded' -test {
    $resources | Should Not BeNullOrEmpty
  }

  It -name "[$api] Create Live Mount" -test {
    # Arrange    
    Mock -CommandName Invoke-WebRequest -Verifiable -MockWith {
      return @{
        Content    = $resources.$api.SuccessMock
        StatusCode = $resources.$api.SuccessCode
      }
    } `
    -ModuleName Rubrik
    
    # Act
    (New-RubrikMount -VM 'TEST1' -api $api).requestId | Should BeExactly 'MOUNT_SNAPSHOT_11111111-2222-3333-4444-555555555555_66666666-7777-8888-9999-000000000000:::0'
    
    # Assert
    Assert-VerifiableMocks
  }
}