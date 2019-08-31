Remove-Module -Name 'Rubrik' -ErrorAction 'SilentlyContinue'
Import-Module -Name './Rubrik/Rubrik.psd1' -Force

Describe -Name 'Public/New-RubrikBootstrap' -Tag 'Public', 'New-RubrikBootstrap' -Fixture {
    InModuleScope -ModuleName Rubrik -ScriptBlock {
        #region init
        $global:rubrikConnection = @{
            id      = 'test-id'
            userId  = 'test-userId'
            token   = 'test-token'
            server  = 'test-server'
            header  = @{ 'Authorization' = 'Bearer test-authorization' }
            time    = (Get-Date)
            api     = 'v1'
            version = '4.0.5'
        }
        #endregion

        Context -Name 'New Log Shipping Results' {
            Mock -CommandName Test-RubrikConnection -Verifiable -ModuleName 'Rubrik' -MockWith {}
            Mock -CommandName Submit-Request -Verifiable -ModuleName 'Rubrik' -MockWith {
                @{
                    'id'       = 'RESTORE_MSSQL_DB_11111'
                    'status'   = 'QUEUED'
                    'progress' = '0'
                }
            }

            It -Name 'Should invoke new log shipping restore with QUEUED status' -Test {
                ( New-RubrikBootstrap -Id 'databaseid' -targetInstanceId 'instance' -targetDatabaseName 'db').status |
                    Should -BeExactly 'QUEUED'
            }
            
            It -Name 'Should invoke new log shipping restore correct ID' -Test {
                ( New-RubrikBootstrap -Id 'databaseid' -targetInstanceId 'instance' -targetDatabaseName 'db').id |
                    Should -BeExactly 'RESTORE_MSSQL_DB_11111'
            }
            
            Assert-VerifiableMock
            Assert-MockCalled -CommandName Test-RubrikConnection -ModuleName 'Rubrik' -Exactly 2
            Assert-MockCalled -CommandName Submit-Request -ModuleName 'Rubrik'  -Exactly 2
        }
        Context -Name 'Parameter Validation' {
            # TODO
        }
    }
}