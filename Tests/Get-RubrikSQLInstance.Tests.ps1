Remove-Module -Name 'Rubrik' -ErrorAction 'SilentlyContinue'
Import-Module -Name './Rubrik/Rubrik.psd1' -Force

foreach ( $privateFunctionFilePath in ( Get-ChildItem -Path './Rubrik/Private' | Where-Object extension -eq '.ps1').FullName  ) {
    . $privateFunctionFilePath
}

Describe -Name 'Public/Get-RubrikSQLInstance' -Tag 'Public', 'Get-RubrikSQLInstance' -Fixture {
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

    Context -Name 'Multiple Results' {
        Mock -CommandName Test-RubrikConnection -Verifiable -ModuleName 'Rubrik' -MockWith {}
        Mock -CommandName Submit-Request -Verifiable -ModuleName 'Rubrik' -MockWith {
            $response = '{
                "hasMore": false,
                "data": [
                  {
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
                    "logRetentionHours": 168,
                    "copyOnly": false,
                    "name": "MSSQLSERVER",
                    "id": "MssqlInstance:::12345678-1234-abcd-8910-1234567890ab",
                    "logBackupFrequencyInSeconds": 900
                  },
                  {
                    "configuredSlaDomainName": "Gold",
                    "primaryClusterId": "12345678-1234-abcd-8910-1234567890ab",
                    "unprotectableReasons": [],
                    "internalTimestamp": 1563754195703000,
                    "configuredSlaDomainId": "12345678-1234-abcd-8910-1234567890ab",
                    "rootProperties": {
                      "rootType": "Host",
                      "rootId": "Host:::12345678-1234-abcd-8910-1234567890ac",
                      "rootName": "sql02.example.us"
                    },
                    "protectionDate": "1970-01-01T00:00:00.000Z",
                    "logRetentionHours": 168,
                    "copyOnly": false,
                    "name": "MSSQLSERVER2",
                    "id": "MssqlInstance:::12345678-1234-abcd-8910-1234567890ac",
                    "logBackupFrequencyInSeconds": 900
                  },
                  {
                    "configuredSlaDomainName": "Silver",
                    "primaryClusterId": "12345678-1234-abcd-8910-1234567890ab",
                    "unprotectableReasons": [],
                    "internalTimestamp": 1563754195703000,
                    "configuredSlaDomainId": "12345678-1234-abcd-8910-1234567890ac",
                    "rootProperties": {
                      "rootType": "Host",
                      "rootId": "Host:::12345678-1234-abcd-8910-1234567890ad",
                      "rootName": "sql03.example.us"
                    },
                    "protectionDate": "1970-01-01T00:00:00.000Z",
                    "logRetentionHours": 168,
                    "copyOnly": false,
                    "name": "MSSQLSERVER3",
                    "id": "MssqlInstance:::12345678-1234-abcd-8910-1234567890ad",
                    "logBackupFrequencyInSeconds": 900
                  }
                ],
                "total": 3
              }'
            return ConvertFrom-Json $response
        }
        It -Name 'runnnig with no parameters should return three results' -Test {
            ( Get-RubrikSQLInstance ).Count |
                Should -BeExactly 3
        }
        It -Name 'should filter on Name' -Test {
            ( Get-RubrikSQLInstance -Name 'MSSQLSERVER' ).Name |
                Should -BeExactly 'MSSQLSERVER'
        }
        It -Name 'should filter on SLA name' -Test {
            ( Get-RubrikSQLInstance -SLA 'Gold' ).Count |
                Should -BeExactly 2
        }
        It -Name 'should filter on Hostname' -Test {
            ( Get-RubrikSQLInstance -Hostname 'sql01.example.us' ).Count |
                Should -BeExactly 1
        }
        Assert-VerifiableMock
        Assert-MockCalled -CommandName Test-RubrikConnection -ModuleName 'Rubrik' -Times 1
        Assert-MockCalled -CommandName Submit-Request -ModuleName 'Rubrik' -Times 1
    }

    Context -Name 'Single Result' {
        Mock -CommandName Test-RubrikConnection -Verifiable -ModuleName 'Rubrik' -MockWith {}
        Mock -CommandName Submit-Request -Verifiable -ModuleName 'Rubrik' -MockWith {
            $response = '{  
                "hasMore":false,
                "data":[  
                    {
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
                        "logRetentionHours": 168,
                        "copyOnly": false,
                        "name": "MSSQLSERVER",
                        "id": "MssqlInstance:::12345678-1234-abcd-8910-1234567890ab",
                        "logBackupFrequencyInSeconds": 900
                      }
                ],
                "total":1
            }'
            return ConvertFrom-Json $response
        }
        It -Name 'one result returned' -Test {
            ( Get-RubrikSQLInstance -ID 'MssqlInstance:::12345678-1234-abcd-8910-1234567890ab' ).Count |
                Should -BeExactly 1
        }
        It -Name 'verify name' -Test {
            ( Get-RubrikSQLInstance -ID 'MssqlInstance:::12345678-1234-abcd-8910-1234567890ab' ).Name |
                Should -BeExactly 'MSSQLSERVER'
        }
        It -Name 'verify ID' -Test {
            ( Get-RubrikSQLInstance -ID 'MssqlInstance:::12345678-1234-abcd-8910-1234567890ab' ).id |
                Should -BeExactly 'MssqlInstance:::12345678-1234-abcd-8910-1234567890ab'
        }
        It -Name 'verify SLA name' -Test {
            ( Get-RubrikSQLInstance -ID 'MssqlInstance:::12345678-1234-abcd-8910-1234567890ab' ).configuredSlaDomainName |
                Should -BeExactly 'Gold'
        }
        It -Name 'verify SLA ID' -Test {
            ( Get-RubrikSQLInstance -ID 'MssqlInstance:::12345678-1234-abcd-8910-1234567890ab' ).configuredSlaDomainId |
                Should -BeExactly '12345678-1234-abcd-8910-1234567890ab'
        }
        Assert-VerifiableMock
        Assert-MockCalled -CommandName Test-RubrikConnection -ModuleName 'Rubrik' -Times 1
        Assert-MockCalled -CommandName Submit-Request -ModuleName 'Rubrik' -Times 1
    }
}