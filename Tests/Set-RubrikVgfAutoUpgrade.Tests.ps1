Remove-Module -Name 'Rubrik' -ErrorAction 'SilentlyContinue'
Import-Module -Name './Rubrik/Rubrik.psd1' -Force

foreach ( $privateFunctionFilePath in ( Get-ChildItem -Path './Rubrik/Private' | Where-Object extension -eq '.ps1').FullName  ) {
    . $privateFunctionFilePath
}

Describe -Name 'Public/Set-RubrikVgfAutoUpgrade' -Tag 'Public', 'Set-RubrikVgfAutoUpgrade' -Fixture {
    #region init
    $global:rubrikConnection = @{
        id      = 'test-id'
        userId  = 'test-userId'
        token   = 'test-token'
        server  = 'test-server'
        header  = @{ 'Authorization' = 'Bearer test-authorization' }
        time    = (Get-Date)
        api     = 'v1'
        version = '5.3'
    }
    #endregion

    Context -Name 'Result Filtering' {
        Mock -CommandName Test-RubrikConnection -Verifiable -ModuleName 'Rubrik' -MockWith {}
        Mock -CommandName Submit-Request -Verifiable -ModuleName 'Rubrik' -MockWith {
            @{
                'migrateFastVirtualDiskBuild'       = 'None'
                'maxFullMigrationStoragePercentage' = 70
            }
        }
        $mockToggle = 'None'
        $mockPercent = 70
        It -Name 'Setting migrateFastVirtualDiskBuild should be successful' -Test {
            ( Set-RubrikVgfAutoUpgrade -migrateFastVirtualDiskBuild $mockToggle ).migrateFastVirtualDiskBuild |
                Should -BeExactly $mockToggle
        }
        It -Name 'Setting maxFullMigrationStoragePercentage should be successful' -Test {
            ( Set-RubrikVgfAutoUpgrade -maxFullMigrationStoragePercentage $mockPercent ).maxFullMigrationStoragePercentage |
                Should -BeExactly $mockPercent
        }
        It -Name 'Setting both configurations should be successful' -Test {
            $result = Set-RubrikVgfAutoUpgrade -migrateFastVirtualDiskBuild $mockToggle -maxFullMigrationStoragePercentage $mockPercent
            $result.migrateFastVirtualDiskBuild |
                Should -BeExactly $mockToggle
            $result.maxFullMigrationStoragePercentage |
                Should -BeExactly $mockPercent
        }
        Assert-VerifiableMock
        Assert-MockCalled -CommandName Test-RubrikConnection -ModuleName 'Rubrik' -Exactly 3
        Assert-MockCalled -CommandName Submit-Request -ModuleName 'Rubrik' -Exactly 3
    }
    Context -Name 'Parameter Validation' {
        It -Name 'Both migrateFastVirtualDiskBuild and maxFullMigrationStoragePercentage should not be empty' -Test {
            ( Set-RubrikVgfAutoUpgrade ) |
                Should -BeExactly $null
        }
    }
}