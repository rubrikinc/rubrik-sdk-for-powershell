Remove-Module -Name 'Rubrik' -ErrorAction 'SilentlyContinue'
Import-Module -Name './Rubrik/Rubrik.psd1' -Force

foreach ( $privateFunctionFilePath in ( Get-ChildItem -Path './Rubrik/Private' | Where-Object extension -eq '.ps1').FullName  ) {
    . $privateFunctionFilePath
}

Describe -Name 'Public/New-RubrikLogShipping' -Tag 'Public', 'New-RubrikLogShipping' -Fixture {
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
            ( New-RubrikLogShipping -Id 'databaseid' -targetInstanceId 'instance' -targetDatabaseName 'db').status |
                Should -BeExactly 'QUEUED'
        }
        
        It -Name 'Should invoke new log shipping restore correct ID' -Test {
            ( New-RubrikLogShipping -Id 'databaseid' -targetInstanceId 'instance' -targetDatabaseName 'db').id |
                Should -BeExactly 'RESTORE_MSSQL_DB_11111'
        }
        
        Assert-VerifiableMock
        Assert-MockCalled -CommandName Test-RubrikConnection -ModuleName 'Rubrik' -Exactly 2
        Assert-MockCalled -CommandName Submit-Request -ModuleName 'Rubrik'  -Exactly 2
    }
    Context -Name 'Parameter Validation' {
        It -Name 'Parameter id is missing' -Test {
            { New-RubrikLogShipping -Id -targetDatabaseName 'db'  } |
                Should -Throw "Missing an argument for parameter 'Id'. Specify a parameter of type 'System.String' and try again."
        }
        It -Name 'Parameter id is empty' -Test {
            { New-RubrikLogShipping -id '' -targetDatabaseName 'db'  } |
                Should -Throw "Cannot bind argument to parameter 'Id' because it is an empty string."
        }
        It -Name 'Parameter targetDatabasename is empty' -Test {
            { New-RubrikLogShipping -id '1111' -targetDatabaseName $null  } |
                Should -Throw "Cannot bind argument to parameter 'targetDatabaseName' because it is an empty string."
        }
        It -Name 'Parameter targetInstanceid is empty' -Test {
            { New-RubrikLogShipping -id '1111' -targetDatabaseName 'db'  -targetInstanceId $null } |
                Should -Throw "Cannot bind argument to parameter 'targetInstanceId' because it is an empty string."
        }
    }
}