Remove-Module -Name 'Rubrik' -ErrorAction 'SilentlyContinue'
Import-Module -Name './Rubrik/Rubrik.psd1' -Force

foreach ( $privateFunctionFilePath in ( Get-ChildItem -Path './Rubrik/Private' | Where-Object extension -eq '.ps1').FullName  ) {
    . $privateFunctionFilePath
}

Describe -Name 'Public/New-RubrikDatabaseMount' -Tag 'Public', 'New-RubrikDatabaseMount' -Fixture {
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

    Context -Name 'Parameters' {
        Mock -CommandName Test-RubrikConnection -Verifiable -ModuleName 'Rubrik' -MockWith {}
        Mock -CommandName Submit-Request -Verifiable -ModuleName 'Rubrik' -MockWith {
            @{
                'id'        = 'RESTORE_MSSQL_DB_databaseid'
                'status'    = 'QUEUED'
                'progress'  = '0'
                'startTime' = '2019-07-02 11:21:22 PM'
            }
        }
        It -Name 'Should return status of queued' -Test {
            ( New-RubrikDatabaseMount -id MssqlDatabase:::12345678-1234-abcd-8910-1234567890ab -targetInstanceId MssqlInstance:::12345678-1234-abcd-8910-1234567890ab -mountedDatabaseName 'ExampleDB1-LM' -recoveryDateTime 'July 2, 2019 7:42:06 PM' ).status |
                Should -BeExactly 'QUEUED'
        }
        Assert-VerifiableMock
        Assert-MockCalled -CommandName Test-RubrikConnection -ModuleName 'Rubrik' -Times 1
        Assert-MockCalled -CommandName Submit-Request -ModuleName 'Rubrik' -Times 1
    }

    Context -Name 'Parameter Validation' {
        It -Name 'Parameter ID cannot be $null' -Test {
            { New-RubrikDatabaseMount -id $null } |
                Should -Throw "Cannot validate argument on parameter 'id'"
        }
        It -Name 'Parameter ID cannot be empty' -Test {
            { New-RubrikDatabaseMount -id '' } |
                Should -Throw "Cannot validate argument on parameter 'id'"
        }
        It -Name 'Parameter MountedDatabaseName cannot be $null' -Test {
            { New-RubrikDatabaseMount -MountedDatabaseName $null } |
                Should -Throw "Cannot validate argument on parameter 'MountedDatabaseName'"
        }
        It -Name 'Parameter MountedDatabaseName cannot be empty' -Test {
            { New-RubrikDatabaseMount -MountedDatabaseName '' } |
                Should -Throw "Cannot validate argument on parameter 'MountedDatabaseName'"
        }
        It -Name 'Parameters TimestampMs and RecoveryDateTime cannot be simultaneously used' -Test {
            { New-RubrikDatabaseMount -TimestampMs 1563374327000 -RecoveryDateTime (Get-Date).AddDays(-1) } |
                Should -Throw "Parameter set cannot be resolved using the specified named parameters."
        }
    }
}