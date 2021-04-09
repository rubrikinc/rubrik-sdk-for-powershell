Remove-Module -Name 'Rubrik' -ErrorAction 'SilentlyContinue'
Import-Module -Name './Rubrik/Rubrik.psd1' -Force

foreach ( $privateFunctionFilePath in ( Get-ChildItem -Path './Rubrik/Private' | Where-Object extension -eq '.ps1').FullName  ) {
    . $privateFunctionFilePath
}

Describe -Name 'Public/Get-RubrikVgfAutoUpgrade' -Tag 'Public', 'Get-RubrikVgfAutoUpgrade' -Fixture {
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

    Context -Name 'Results Filtering' {
        Mock -CommandName Test-RubrikConnection -Verifiable -ModuleName 'Rubrik' -MockWith {}
        Mock -CommandName Submit-Request -Verifiable -ModuleName 'Rubrik' -MockWith {
            @{
                'migrateFastVirtualDiskBuild'       = 'None'
                'maxFullMigrationStoragePercentage' = 70
            }
        }
        It -Name 'Requesting migrateFastVirtualDiskBuild should return value of None' -Test {
            ( Get-RubrikVgfAutoUpgrade ).migrateFastVirtualDiskBuild |
                Should -BeExactly 'None'
        }
        It -Name 'Requesting maxFullMigrationStoragePercentage should return value of 70' -Test {
            ( Get-RubrikVgfAutoUpgrade ).maxFullMigrationStoragePercentage |
                Should -BeExactly 70
        }
        Assert-VerifiableMock
        Assert-MockCalled -CommandName Test-RubrikConnection -ModuleName 'Rubrik' -Exactly 2
        Assert-MockCalled -CommandName Submit-Request -ModuleName 'Rubrik' -Exactly 2
    }
}