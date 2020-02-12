Remove-Module -Name 'Rubrik' -ErrorAction 'SilentlyContinue'
Import-Module -Name './Rubrik/Rubrik.psd1' -Force

foreach ( $privateFunctionFilePath in ( Get-ChildItem -Path './Rubrik/Private' | Where-Object extension -eq '.ps1').FullName  ) {
    . $privateFunctionFilePath
}

Describe -Name 'Public/Get-RubrikDatabase' -Tag 'Public', 'Get-RubrikDatabase' -Fixture {
    #region init
    $global:rubrikConnection = @{
        id      = 'test-id'
        userId  = 'test-userId'
        token   = 'test-token'
        server  = 'test-server'
        header  = @{ 'Authorization' = 'Bearer test-authorization' }
        time    = (Get-Date)
        api     = 'v1'
        version = '1.0'
    }
    #endregion

    Context -Name 'Multiple Results' {
        Mock -CommandName Test-RubrikConnection -Verifiable -ModuleName 'Rubrik' -MockWith {}
        Mock -CommandName Get-RubrikSLA -Verifiable -ModuleName 'Rubrik' -MockWith {
            @{ 'id' = 'Gold' }
        }
        Mock -CommandName Submit-Request -Verifiable -ModuleName 'Rubrik' -MockWith {
            $response = '{  
                "hasMore":false,
                "data":[  
                    {
                        "effectiveSlaDomainId": "12345678-1234-abcd-8910-1234567890ab",
                        "primaryClusterId": "12345678-1234-abcd-8910-1234567890ab",
                        "instanceName": "MSSQLSERVER",
                        "unprotectableReasons": [],
                        "configuredSlaDomainId": "12345678-1234-abcd-8910-1234567890ab",
                        "isLogShippingSecondary": false,
                        "effectiveSlaDomainName": "Gold",
                        "instanceId": "MssqlInstance:::12345678-1234-abcd-8910-1234567890ab",
                        "recoveryModel": "FULL",
                        "id": "MssqlDatabase:::12345678-1234-abcd-8910-1234567890ab",
                        "state": "ONLINE",
                        "configuredSlaDomainName": "Gold",
                        "replicas": [],
                        "slaAssignment": "Direct",
                        "rootProperties": {
                            "rootType": "Host",
                            "rootId": "Host:::12345678-1234-abcd-8910-1234567890ab",
                            "rootName": "sqlserver.example.us"
                        },
                        "logBackupRetentionHours": 24,
                        "isRelic": false,
                        "name": "ExampleDB1",
                        "logBackupFrequencyInSeconds": 300
                    },
                    {
                        "effectiveSlaDomainId": "12345678-1234-abcd-8910-1234567890ab",
                        "primaryClusterId": "12345678-1234-abcd-8910-1234567890ab",
                        "instanceName": "MSSQLSERVER",
                        "unprotectableReasons": [],
                        "configuredSlaDomainId": "12345678-1234-abcd-8910-1234567890ab",
                        "isLogShippingSecondary": false,
                        "effectiveSlaDomainName": "Gold",
                        "instanceId": "MssqlInstance:::12345678-1234-abcd-8910-1234567890ab",
                        "recoveryModel": "FULL",
                        "id": "MssqlDatabase:::12345678-1234-abcd-8910-1234567890ac",
                        "state": "ONLINE",
                        "configuredSlaDomainName": "Gold",
                        "replicas": [],
                        "slaAssignment": "Direct",
                        "rootProperties": {
                            "rootType": "Host",
                            "rootId": "Host:::12345678-1234-abcd-8910-1234567890ab",
                            "rootName": "sqlserver.example.us"
                        },
                        "logBackupRetentionHours": 24,
                        "isRelic": true,
                        "name": "ExampleDB2",
                        "logBackupFrequencyInSeconds": 300
                    },
                    {
                        "effectiveSlaDomainId": "12345678-1234-abcd-8910-1234567890ac",
                        "primaryClusterId": "12345678-1234-abcd-8910-1234567890ab",
                        "instanceName": "MSSQLSERVER2",
                        "unprotectableReasons": [],
                        "configuredSlaDomainId": "12345678-1234-abcd-8910-1234567890ac",
                        "isLogShippingSecondary": false,
                        "effectiveSlaDomainName": "Silver",
                        "instanceId": "MssqlInstance:::12345678-1234-abcd-8910-1234567890ac",
                        "recoveryModel": "FULL",
                        "id": "MssqlDatabase:::12345678-1234-abcd-8910-1234567890ad",
                        "state": "ONLINE",
                        "configuredSlaDomainName": "Silver",
                        "replicas": [],
                        "slaAssignment": "Direct",
                        "rootProperties": {
                            "rootType": "Host",
                            "rootId": "Host:::12345678-1234-abcd-8910-1234567890ab",
                            "rootName": "sqlserver2.example.us"
                        },
                        "logBackupRetentionHours": 24,
                        "isRelic": false,
                        "name": "ExampleDB3",
                        "logBackupFrequencyInSeconds": 300
                    }
                ],
                "total":3
            }'
            return ConvertFrom-Json $response
        }
        It -Name 'runnnig with no parameters should return three results' -Test {
            ( Get-RubrikDatabase ).Count |
                Should -BeExactly 3
        }
        It -Name 'query based on PrimaryClusterID' -Test {
            ( Get-RubrikDatabase -PrimaryClusterID '12345678-1234-abcd-8910-1234567890ab' ).Count |
                Should -BeExactly 3
        }
        It -Name 'should filter on Name' -Test {
            ( Get-RubrikDatabase -Name 'ExampleDB1' ).Name |
                Should -BeExactly 'ExampleDB1'
        }
        It -Name 'should filter on SLA name' -Test {
            ( Get-RubrikDatabase -SLA 'Gold' ).Count |
                Should -BeExactly 2
        }
        It -Name 'should filter on Instance' -Test {
            ( Get-RubrikDatabase -Instance 'MSSQLSERVER' ).Count |
                Should -BeExactly 2
        }
        It -Name 'should filter on Hostname' -Test {
            ( Get-RubrikDatabase -Hostname 'sqlserver.example.us' ).Count |
                Should -BeExactly 2
        }
        It -Name 'should filter on ServerInstance' -Test {
            ( Get-RubrikDatabase -ServerInstance 'sqlserver.example.us\MSSQLSERVER' ).Count |
                Should -BeExactly 2
        }
        Assert-VerifiableMock
        Assert-MockCalled -CommandName Test-RubrikConnection -ModuleName 'Rubrik' -Exactly 8
        Assert-MockCalled -CommandName Get-RubrikSLA -ModuleName 'Rubrik' -Exactly 1
        Assert-MockCalled -CommandName Submit-Request -ModuleName 'Rubrik' -Exactly 8
    }

    Context -Name 'Single Result' {
        Mock -CommandName Test-RubrikConnection -Verifiable -ModuleName 'Rubrik' -MockWith {}
        Mock -CommandName Submit-Request -Verifiable -ModuleName 'Rubrik' -MockWith {
            $response = ' 
                    {
                        "effectiveSlaDomainId": "12345678-1234-abcd-8910-1234567890ab",
                        "primaryClusterId": "12345678-1234-abcd-8910-1234567890ab",
                        "instanceName": "MSSQLSERVER",
                        "unprotectableReasons": [],
                        "configuredSlaDomainId": "12345678-1234-abcd-8910-1234567890ab",
                        "isLogShippingSecondary": false,
                        "effectiveSlaDomainName": "Gold",
                        "instanceId": "MssqlInstance:::12345678-1234-abcd-8910-1234567890ab",
                        "recoveryModel": "FULL",
                        "id": "MssqlDatabase:::12345678-1234-abcd-8910-1234567890ab",
                        "state": "ONLINE",
                        "configuredSlaDomainName": "Gold",
                        "replicas": [],
                        "slaAssignment": "Direct",
                        "rootProperties": {
                            "rootType": "Host",
                            "rootId": "Host:::12345678-1234-abcd-8910-1234567890ab",
                            "rootName": "sqlserver.example.us"
                        },
                        "logBackupRetentionHours": 24,
                        "isRelic": false,
                        "name": "ExampleDB1",
                        "logBackupFrequencyInSeconds": 300
                    }'
            return ConvertFrom-Json $response
        }
        It -Name 'one result returned' -Test {
            @( Get-RubrikDatabase -ID 'MssqlDatabase:::12345678-1234-abcd-8910-1234567890ab' ).Count |
                Should -BeExactly 1
        }
        It -Name 'verify name' -Test {
            ( Get-RubrikDatabase -ID 'MssqlDatabase:::12345678-1234-abcd-8910-1234567890ab' ).Name |
                Should -BeExactly 'ExampleDB1'
        }
        It -Name 'verify SLA name' -Test {
            ( Get-RubrikDatabase -ID 'MssqlDatabase:::12345678-1234-abcd-8910-1234567890ab' ).effectiveSlaDomainName |
                Should -BeExactly 'Gold'
        }
        It -Name 'verify SLA ID' -Test {
            ( Get-RubrikDatabase -ID 'MssqlDatabase:::12345678-1234-abcd-8910-1234567890ab' ).effectiveSlaDomainId |
                Should -BeExactly '12345678-1234-abcd-8910-1234567890ab'
        }
        It -Name 'verify Instance' -Test {
            ( Get-RubrikDatabase -ID 'MssqlDatabase:::12345678-1234-abcd-8910-1234567890ab').instanceName |
                Should -BeExactly 'MSSQLSERVER'
        }
        Assert-VerifiableMock
        Assert-MockCalled -CommandName Test-RubrikConnection -ModuleName 'Rubrik' -Exactly 5
        Assert-MockCalled -CommandName Submit-Request -ModuleName 'Rubrik' -Exactly 5
    }

    Context -Name 'Parameter Validation' {
        It -Name 'Parameter ID cannot be $null' -Test {
            { Get-RubrikDatabase -Id $null } |
                Should -Throw "Cannot validate argument on parameter 'ID'"
        }
        It -Name 'Parameter ID cannot be empty' -Test {
            { Get-RubrikDatabase -Id '' } |
                Should -Throw "Cannot validate argument on parameter 'ID'"
        }
        It -Name 'Parameters Id and Name cannot be simultaneously used' -Test {
            { Get-RubrikDatabase -Id 'MssqlDatabase:::12345678-1234-abcd-8910-1234567890ab' -Name 'ExampleDB1' } |
                Should -Throw "Parameter set cannot be resolved using the specified named parameters."
        }
    }
    Context -Name 'Validate AG Group filtering' {
        Mock -CommandName Test-RubrikConnection -Verifiable -ModuleName 'Rubrik' -MockWith {}
        Mock -CommandName Get-RubrikAvailabilityGroup -Verifiable -ParameterFilter {$GroupName -eq 'BestAG'} -Module 'Rubrik' -MockWith {
            [pscustomobject]@{
                id = 'MssqlAvailabilityGroup:::12345678-1234-abcd-8910-abbaabcdef90'
            }
        }
        Mock -CommandName Get-RubrikAvailabilityGroup -Verifiable -ModuleName 'Rubrik' -MockWith {} 
        Mock -CommandName Submit-Request -Verifiable -ModuleName 'Rubrik' -MockWith {
            $response = '{  
                "hasMore":false,
                "data":[  
                    {
                        "availabilityGroupId": "MssqlAvailabilityGroup:::12345678-1234-abcd-8910-abbaabcdef90",
                        "effectiveSlaDomainId": "12345678-1234-abcd-8910-1234567890ab",
                        "effectiveSlaDomainName": "Gold",
                        "primaryClusterId": "12345678-1234-abcd-8910-1234567890ab",
                        "instanceName": "MSSQLSERVER",
                        "name": "DB1"
                    },
                    {
                        "availabilityGroupId": "MssqlAvailabilityGroup:::12345678-1234-abcd-8910-abbaabcdef90",
                        "effectiveSlaDomainId": "12345678-1234-abcd-8910-1234567890ab",
                        "effectiveSlaDomainName": "Gold",
                        "primaryClusterId": "12345678-1234-abcd-8910-1234567890ab",
                        "instanceName": "MSSQLSERVER",
                        "name": "DB2"
                    },
                    {
                        "availabilityGroupId": "MssqlAvailabilityGroup:::12345678-1234-abcd-8910-abbaabcdef00",
                        "effectiveSlaDomainId": "12345678-1234-abcd-8910-1234567890ab",
                        "effectiveSlaDomainName": "Gold",
                        "primaryClusterId": "12345678-1234-abcd-8910-1234567890ab",
                        "instanceName": "MSSQLSERVER",
                        "name": "DB3"
                    }
                ],
                "total":3
            }'
            return ConvertFrom-Json $response
        }
        It -Name 'Get all databases' -Test {
            (Get-RubrikDatabase).Count |
                Should -BeExactly 3
        }
        It -Name 'Get Databases by availability group ID' -Test {
            (Get-RubrikDatabase -AvailabilityGroupID 'MssqlAvailabilityGroup:::12345678-1234-abcd-8910-abbaabcdef90').Count |
                Should -BeExactly 2
        }
        It -Name 'Get Databases by availability group Name' -Test {
            (Get-RubrikDatabase -AvailabilityGroupName BestAG).count |
                Should -BeExactly 2
        }
        It -Name 'Get Databases by availability group name - Verify ID' -Test {
            (Get-RubrikDatabase -AvailabilityGroupName BestAG).availabilityGroupId |
                Should -Contain 'MssqlAvailabilityGroup:::12345678-1234-abcd-8910-abbaabcdef90'
        }
        It -Name 'Get Databases by availability group name and database name' -Test {
            (Get-RubrikDatabase -AvailabilityGroupName BestAG -Name DB2).Name |
                Should -BeExactly 'DB2'
        }        
        It -Name 'Get Databases by incorrect availability group name, return no results' -Test {
            (Get-RubrikDatabase -AvailabilityGroupName WorstAG) |
                Should -BeNullOrEmpty
        }
        
        Assert-VerifiableMock
        Assert-MockCalled -CommandName Test-RubrikConnection -ModuleName 'Rubrik' -Exactly 6
        Assert-MockCalled -CommandName Submit-Request -ModuleName 'Rubrik' -Exactly 6
        Assert-MockCalled -CommandName Get-RubrikAvailabilityGroup -ModuleName 'Rubrik' -Exactly 4
    }
}