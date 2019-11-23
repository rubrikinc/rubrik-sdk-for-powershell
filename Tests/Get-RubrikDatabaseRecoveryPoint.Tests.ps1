Remove-Module -Name 'Rubrik' -ErrorAction 'SilentlyContinue'
Import-Module -Name './Rubrik/Rubrik.psd1' -Force

foreach ( $privateFunctionFilePath in ( Get-ChildItem -Path './Rubrik/Private' | Where-Object extension -eq '.ps1').FullName  ) {
    . $privateFunctionFilePath
}

Describe -Name 'Public/Get-RubrikDatabaseRecoveryPoint' -Tag 'Public', 'Get-RubrikDatabaseRecoveryPoint' -Fixture{
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

    Context -Name 'No Rubrik API Calls' {
        It -Name 'User enters in date and time' -Test {
            $date = (Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ss.fffZ')
            Get-RubrikDatabaseRecoveryPoint -id 'MssqlDatabase:::12345678-1234-abcd-8910-1234567890ab' -RestoreTime $date | Should -Be $date
        }

        It -Name 'User enters in just the time' -Test {
            $date = (Get-Date).ToUniversalTime().ToString('HH:mm')
            $today_at_date = $(Get-Date $date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ss.fffZ')
            Get-RubrikDatabaseRecoveryPoint -id 'MssqlDatabase:::12345678-1234-abcd-8910-1234567890ab' -RestoreTime $date | Should -Be $today_at_date
        }

        It -Name 'User enters date in the future' -Test {
            $date = (Get-Date).AddDays(1).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ss.fffZ')
            $today_at_date = $(Get-Date $date).AddDays(-1).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ss.fffZ')
            Get-RubrikDatabaseRecoveryPoint -id 'MssqlDatabase:::12345678-1234-abcd-8910-1234567890ab' -RestoreTime $date | Should -Be $today_at_date
        }
    }
    Context -Name 'With Rubrik API Calls' {
        It -Name 'When user uses Latest switch' -Test {
            Mock -CommandName Test-RubrikConnection -Verifiable -ModuleName 'Rubrik' -MockWith { }
            Mock -CommandName Submit-Request -Verifiable -ModuleName 'Rubrik' -MockWith {
                $response = '
                    {
                        "hasPermissions": true,
                        "effectiveSlaDomainId": "12345678-1234-abcd-8910-1234567890ab",
                        "oldestRecoveryPoint": "2018-10-26T23:53:00.000Z",
                        "primaryClusterId": "12345678-1234-abcd-8910-1234567890ab",
                        "instanceName": "MSSQLSERVER",
                        "unprotectableReasons": [],
                        "effectiveSlaSourceObjectId": "MssqlInstance:::12345678-1234-abcd-8910-1234567890ab",
                        "localStorage": 332687785,
                        "effectiveSlaSourceObjectName": "MSSQLSERVER",
                        "isOnline": true,
                        "configuredSlaDomainId": "12345678-1234-abcd-8910-1234567890ab",
                        "isLogShippingSecondary": false,
                        "effectiveSlaDomainName": "Gold",
                        "instanceId": "MssqlInstance:::12345678-1234-abcd-8910-1234567890ab",
                        "copyOnly": false,
                        "recoveryModel": "FULL",
                        "recoveryForkGuid": "4CB48A18-E1A9-47D3-B742-0E1C1C37D5AE",
                        "id": "MssqlDatabase:::12345678-1234-abcd-8910-1234567890ab",
                        "state": "ONLINE",
                        "isInAvailabilityGroup": false,
                        "isLiveMount": false,
                        "configuredSlaDomainName": "Gold",
                        "replicas": [
                            {
                                "instanceId": "MssqlInstance:::12345678-1234-abcd-8910-1234567890ab",
                                "instanceName": "MSSQLSERVER",
                                "recoveryModel": "FULL",
                                "state": "ONLINE",
                                "hasPermissions": true,
                                "isStandby": false,
                                "recoveryForkGuid": "4CB48A18-E1A9-47D3-B742-0E1C1C37D5AE",
                                "isArchived": false,
                                "isDeleted": false,
                                    "rootProperties": {
                                    "rootType": "Host",
                                    "rootId": "Host:::12345678-1234-abcd-8910-1234567890ab",
                                    "rootName": "sqlserver.example.us"
                                }
                            }
                        ],
                        "latestRecoveryPoint": "2019-10-25T00:44:16.000Z",
                        "slaAssignment": "Direct",
                        "rootProperties": {
                            "rootType": "Host",
                            "rootId": "Host:::12345678-1234-abcd-8910-1234567890ab",
                            "rootName": "sqlserver.example.us"
                        },
                        "isLocal": true,
                        "protectionDate": "2019-03-19T19:20:45.760Z",
                        "logBackupRetentionHours": 24,
                        "isRelic": false,
                        "snapshotCount": 50,
                        "name": "ExampleDB1",
                        "isStandby": false,
                        "archiveStorage": 943775336,
                        "logBackupFrequencyInSeconds": 300
                    }'
                return ConvertFrom-Json $response
            }

            (Get-RubrikDatabaseRecoveryPoint -id 'MssqlDatabase:::12345678-1234-abcd-8910-1234567890ab' -Latest) | Should -Be (Get-Date -Date '2019-10-25T00:44:16.000Z').ToUniversalTime()
        }
                
        It -Name 'When user uses LastFull switch' -Test {
            Mock -CommandName Test-RubrikConnection -Verifiable -ModuleName 'Rubrik' -MockWith { }
            Mock -CommandName Submit-Request -Verifiable -ModuleName 'Rubrik' -MockWith {
                $response = '
                    {
                        "hasMore": false,
                        "data": [
                            {
                                "date": "2019-08-01T01:00:00.000Z",
                                "indexState": 1,
                                "slaName": "Gold",
                                "vmName": "Example-VM",
                                "slaId": "12345678-1234-abcd-8910-1234567890ab",
                                "replicationLocationIds": [],
                                "archivalLocationIds": [],
                                "isOnDemandSnapshot": false,
                                "cloudState": 2,
                                "id": "4d70bd92-71b3-44cd-8bbb-0a89c0247bfd",
                                "consistencyLevel": "CRASH_CONSISTENT"
                            },
                            {
                                "date": "2019-08-02T01:00:00.000Z",
                                "indexState": 1,
                                "slaName": "Gold",
                                "vmName": "Example-VM",
                                "slaId": "12345678-1234-abcd-8910-1234567890ab",
                                "replicationLocationIds": [],
                                "archivalLocationIds": [],
                                "isOnDemandSnapshot": true,
                                "cloudState": 0,
                                "id": "2ec41b1d-6411-4cb4-b4a8-9ea621c915be",
                                "consistencyLevel": "CRASH_CONSISTENT"
                            },
                            {
                                "date": "2019-08-03T01:00:00.000Z",
                                "indexState": 1,
                                "slaName": "Gold",
                                "vmName": "Example-VM",
                                "slaId": "12345678-1234-abcd-8910-1234567890ab",
                                "replicationLocationIds": [],
                                "archivalLocationIds": [],
                                "isOnDemandSnapshot": false,
                                "cloudState": 0,
                                "id": "ca214725-6dcd-49b4-88ae-45780b16879a",
                                "consistencyLevel": "CRASH_CONSISTENT"
                            },
                            {
                                "date": "2019-08-04T01:00:00.000Z",
                                "indexState": 1,
                                "slaName": "Gold",
                                "vmName": "Example-VM",
                                "slaId": "12345678-1234-abcd-8910-1234567890ab",
                                "replicationLocationIds": [],
                                "archivalLocationIds": [],
                                "isOnDemandSnapshot": false,
                                "cloudState": 0,
                                "id": "87a5acac-caaa-48f9-b880-be0c759e05c2",
                                "consistencyLevel": "CRASH_CONSISTENT"
                            },
                            {
                                "date": "2019-08-05T01:00:00.000Z",
                                "indexState": 1,
                                "slaName": "Gold",
                                "vmName": "Example-VM",
                                "slaId": "12345678-1234-abcd-8910-1234567890ab",
                                "replicationLocationIds": [],
                                "archivalLocationIds": [],
                                "isOnDemandSnapshot": false,
                                "cloudState": 0,
                                "id": "b42ed6ba-760e-425f-a35d-c7dc5636b55d",
                                "consistencyLevel": "CRASH_CONSISTENT"
                            }
                        ],
                        "total": 5
                    }'
                return ConvertFrom-Json $response
            }
            Get-RubrikDatabaseRecoveryPoint -id 'MssqlDatabase:::12345678-1234-abcd-8910-1234567890ab' -LastFull | Should -Be (Get-Date -Date '2019-08-05T01:00:00.000Z').ToUniversalTime()
        }
        Assert-VerifiableMock
        Assert-MockCalled -CommandName Test-RubrikConnection -ModuleName 'Rubrik' -Exactly 2
        Assert-MockCalled -CommandName Submit-Request -ModuleName 'Rubrik' -Exactly 2
    }
}