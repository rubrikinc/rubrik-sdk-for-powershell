Remove-Module -Name 'Rubrik' -ErrorAction 'SilentlyContinue'
Import-Module -Name './Rubrik/Rubrik.psd1' -Force

foreach ( $privateFunctionFilePath in ( Get-ChildItem -Path './Rubrik/Private' | Where-Object extension -eq '.ps1').FullName  ) {
    . $privateFunctionFilePath
}

Describe -Name 'Public/Set-RubrikSQLInstance' -Tag 'Public', 'Set-RubrikSQLInstance' -Fixture {
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
            $response = '{
                "configuredSlaDomainName": "Gold",
                "primaryClusterId": "12345678-1234-abcd-8910-1234567890ab",
                "unprotectableReasons": [],
                "internalTimestamp": 1563754195703000,
                "configuredSlaDomainId": "12345678-1234-abcd-8910-1234567890ab",
                "rootProperties": {
                  "rootType": "Host",
                  "rootId": "Host:::12345678-1234-abcd-8910-1234567890ab",
                  "rootName": "sql01.example.us"
                },
                "protectionDate": "1970-01-01T00:00:00.000Z",
                "copyOnly": false,
                "name": "MSSQLSERVER",
                "id": "MssqlInstance:::12345678-1234-abcd-8910-1234567890ab",
                "logRetentionHours": 168,
                "logBackupFrequencyInSeconds": 900
              }'
            return ConvertFrom-Json $response
        }
        It -Name 'verify name' -Test {
            ( Set-RubrikSQLInstance -ID 'MssqlInstance:::12345678-1234-abcd-8910-1234567890ab' -logRetentionHours 168).Name |
                Should -BeExactly 'MSSQLSERVER'
        }
        It -Name 'verify ID' -Test {
            ( Set-RubrikSQLInstance -ID 'MssqlInstance:::12345678-1234-abcd-8910-1234567890ab' -logRetentionHours 168 ).id |
                Should -BeExactly 'MssqlInstance:::12345678-1234-abcd-8910-1234567890ab'
        }
        It -Name 'verify SLA name' -Test {
            ( Set-RubrikSQLInstance -ID 'MssqlInstance:::12345678-1234-abcd-8910-1234567890ab' -logRetentionHours 168 ).configuredSlaDomainName |
                Should -BeExactly 'Gold'
        }
        It -Name 'verify SLA ID' -Test {
            ( Set-RubrikSQLInstance -ID 'MssqlInstance:::12345678-1234-abcd-8910-1234567890ab' -logRetentionHours 168 ).configuredSlaDomainId |
                Should -BeExactly '12345678-1234-abcd-8910-1234567890ab'
        }
        It -Name 'verify logBackupFrequencyInSeconds' -Test {
            ( Set-RubrikSQLInstance -ID 'MssqlInstance:::12345678-1234-abcd-8910-1234567890ab' -logRetentionHours 168 ).logBackupFrequencyInSeconds |
                Should -BeExactly 900
        }
        It -Name 'verify logRetentionHours' -Test {
            ( Set-RubrikSQLInstance -ID 'MssqlInstance:::12345678-1234-abcd-8910-1234567890ab' -logRetentionHours 168 ).logRetentionHours |
                Should -BeExactly 168
        }
        It -Name 'verify copyOnly' -Test {
            ( Set-RubrikSQLInstance -ID 'MssqlInstance:::12345678-1234-abcd-8910-1234567890ab' -logRetentionHours 168 ).copyOnly |
                Should -BeExactly $false
        }
        Assert-VerifiableMock
        Assert-MockCalled -CommandName Test-RubrikConnection -ModuleName 'Rubrik' -Exactly 7
        Assert-MockCalled -CommandName Submit-Request -ModuleName 'Rubrik' -Exactly 7
    }

    Context -Name 'Parameter Validation' {
        It -Name 'Parameter ID cannot be $null' -Test {
            { Set-RubrikSQLInstance -Id $null } |
                Should -Throw "Cannot validate argument on parameter 'ID'"
        }
        It -Name 'Parameter ID cannot be empty' -Test {
            { Set-RubrikSQLInstance -Id '' } |
                Should -Throw "Cannot validate argument on parameter 'ID'"
        }
    }
}