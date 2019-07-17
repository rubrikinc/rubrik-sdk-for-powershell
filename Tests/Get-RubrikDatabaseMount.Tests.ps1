Remove-Module -Name 'Rubrik' -ErrorAction 'SilentlyContinue'
Import-Module -Name './Rubrik/Rubrik.psd1' -Force

foreach ( $privateFunctionFilePath in ( Get-ChildItem -Path './Rubrik/Private' | Where-Object extension -eq '.ps1').FullName  ) {
    . $privateFunctionFilePath
}

Describe -Name 'Public/Get-RubrikDatabaseMount' -Tag 'Public', 'Get-RubrikDatabaseMount' -Fixture {
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
                    "id": "01234567-8910-1abc-d435-0abc1234d567",
                    "sourceDatabaseId": "MssqlDatabase:::12345678-1234-abcd-8910-1234567890ab",
                    "sourceDatabaseName": "ExampleDB1",
                    "sourceRecoveryPoint": {
                      "timestampMs": 1563370199000
                    },
                    "targetInstanceId": "MssqlInstance:::12345678-1234-abcd-8910-1234567890ab",
                    "targetRootName": "sqlserver.example.us",
                    "creationDate": "2010-01-01T00:00:00.001Z",
                    "ownerId": "01234567-8910-1abc-d435-0abc1234d567_01234567-8910-1abc-d435-0abc1234d567",
                    "ownerName": "Joe User",
                    "status": "Available",
                    "mountedDatabaseId": "MssqlDatabase:::12345678-1234-abcd-8910-1234567890ac",
                    "mountedDatabaseName": "ExampleDB1-Mount1"
                  },
                  {
                    "id": "01234567-8910-1abc-d435-0abc1234d568",
                    "sourceDatabaseId": "MssqlDatabase:::12345678-1234-abcd-8910-1234567890ab",
                    "sourceDatabaseName": "ExampleDB1",
                    "sourceRecoveryPoint": {
                      "timestampMs": 1563326991000
                    },
                    "targetInstanceId": "MssqlInstance:::12345678-1234-abcd-8910-1234567890ab",
                    "targetRootName": "sqlserver.example.us",
                    "creationDate": "2010-01-01T00:00:00.001Z",
                    "ownerId": "01234567-8910-1abc-d435-0abc1234d567_01234567-8910-1abc-d435-0abc1234d567",
                    "ownerName": "Joe User",
                    "status": "Available",
                    "mountedDatabaseId": "MssqlDatabase:::12345678-1234-abcd-8910-1234567890ad",
                    "mountedDatabaseName": "ExampleDB1-Mount2"
                  }
                ],
                "total": 2
              }'
            return ConvertFrom-Json $response
        }
        It -Name 'Runnnig with no parameters should return two results' -Test {
            ( Get-RubrikDatabaseMount ).Count |
                Should -BeExactly 2
        }
        It -Name 'Query based on ID' -Test {
            ( Get-RubrikDatabaseMount -id 'MssqlDatabase:::12345678-1234-abcd-8910-1234567890ab' ).Count |
                Should -BeExactly 2
        }
        It -Name 'Query based on SourceDatabaseName' -Test {
            ( Get-RubrikDatabaseMount -SourceDatabaseName 'ExampleDB1' ).Count |
                Should -BeExactly 2
        }
        It -Name 'Query based on TargetInstanceId' -Test {
            ( Get-RubrikDatabaseMount -TargetInstanceId 'MssqlInstance:::12345678-1234-abcd-8910-1234567890ab' ).Count |
                Should -BeExactly 2
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
                        "id": "01234567-8910-1abc-d435-0abc1234d567",
                        "sourceDatabaseId": "MssqlDatabase:::12345678-1234-abcd-8910-1234567890ab",
                        "sourceDatabaseName": "ExampleDB1",
                        "sourceRecoveryPoint": {
                          "timestampMs": 1563370199000
                        },
                        "targetInstanceId": "MssqlInstance:::12345678-1234-abcd-8910-1234567890ab",
                        "targetRootName": "sqlserver.example.us",
                        "creationDate": "2010-01-01T00:00:00.001Z",
                        "ownerId": "01234567-8910-1abc-d435-0abc1234d567_01234567-8910-1abc-d435-0abc1234d567",
                        "ownerName": "Joe User",
                        "status": "Available",
                        "mountedDatabaseId": "MssqlDatabase:::12345678-1234-abcd-8910-1234567890ac",
                        "mountedDatabaseName": "ExampleDB1-Mount1"
                      }
                ],
                "total":1
            }'
            return ConvertFrom-Json $response
        }
        It -Name 'Query based on ID' -Test {
            ( Get-RubrikDatabaseMount -id 'MssqlDatabase:::12345678-1234-abcd-8910-1234567890ab' ).Count |
                Should -BeExactly 1
        }
        It -Name 'Results match expected values' -Test {
            $results = Get-RubrikDatabaseMount -ID 'MssqlDatabase:::12345678-1234-abcd-8910-1234567890ab'
            $results.sourceDatabaseName | Should -BeExactly 'ExampleDB1'
            $results.targetInstanceId | Should -BeExactly 'MssqlInstance:::12345678-1234-abcd-8910-1234567890ab'
            $results.targetRootName | Should -BeExactly 'sqlserver.example.us'
            $results.mountedDatabaseName | Should -BeExactly 'ExampleDB1-Mount1'
            $results.mountedDatabaseId | Should -BeExactly 'MssqlDatabase:::12345678-1234-abcd-8910-1234567890ac'
            $results.status | Should -BeExactly "Available"
        }
        It -Name 'Query based on MountedDatabaseName' -Test {
            ( Get-RubrikDatabaseMount -MountedDatabaseName 'ExampleDB1-Mount1' ).Count |
                Should -BeExactly 1
        }
        It -Name 'Query based on SourceDatabaseName' -Test {
            ( Get-RubrikDatabaseMount -SourceDatabaseName 'ExampleDB1' ).Count |
                Should -BeExactly 1
        }
        It -Name 'Query based on TargetInstanceId' -Test {
            ( Get-RubrikDatabaseMount -TargetInstanceId 'MssqlInstance:::12345678-1234-abcd-8910-1234567890ab' ).Count |
                Should -BeExactly 1
        }
        Assert-VerifiableMock
        Assert-MockCalled -CommandName Test-RubrikConnection -ModuleName 'Rubrik' -Times 1
        Assert-MockCalled -CommandName Submit-Request -ModuleName 'Rubrik' -Times 1
    }

    <#
    Context -Name 'Parameter Validation' {
        It -Name 'Parameter ID cannot be $null' -Test {
            { Get-RubrikDatabaseMount -Id $null } |
                Should -Throw "Cannot validate argument on parameter 'ID'"
        }
        It -Name 'Parameter ID cannot be empty' -Test {
            { Get-RubrikDatabaseMount -Id '' } |
                Should -Throw "Cannot validate argument on parameter 'ID'"
        }
        It -Name 'Parameters Id and Name cannot be simultaneously used' -Test {
            { Get-RubrikDatabaseMount -Id 'MssqlDatabase:::12345678-1234-abcd-8910-1234567890ab' -Name 'ExampleDB1' } |
                Should -Throw "Parameter set cannot be resolved using the specified named parameters."
        }
    }
    #>
}