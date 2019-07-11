Remove-Module -Name 'Rubrik' -ErrorAction 'SilentlyContinue'
Import-Module -Name './Rubrik/Rubrik.psd1' -Force

foreach ( $privateFunctionFilePath in ( Get-ChildItem -Path './Rubrik/Private' | Where-Object extension -eq '.ps1').FullName  ) {
    . $privateFunctionFilePath
}

Describe -Name 'Public/Get-RubrikSLA' -Tag 'Public', 'Get-RubrikSLA' -Fixture {
    Context -Name 'Parameter/Name-v1' {
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
        Mock -CommandName Test-RubrikConnection -Verifiable -ModuleName 'Rubrik' -MockWith {}
        Mock -CommandName Submit-Request -Verifiable -ModuleName 'Rubrik' -MockWith {
            $response = '{  
                "hasMore":false,
                "data":[  
                    {  
                      "id":"12345678-1234-abcd-8910-1234567890ab",
                      "primaryClusterId":"12345678-1234-abcd-8910-1234567890ab",
                      "name":"Gold",
                      "frequencies":[  
                        {  
                        "timeUnit":"Hourly",
                        "frequency":8,
                        "retention":72
                        },
                        {  
                        "timeUnit":"Daily",
                        "frequency":1,
                        "retention":30
                        },
                        {
                        "timeUnit": "Weekly",
                        "frequency": 1,
                        "retention": 4
                        },
                        {  
                        "timeUnit":"Monthly",
                        "frequency":1,
                        "retention":12
                        },
                        {  
                        "timeUnit":"Yearly",
                        "frequency":1,
                        "retention":2
                        }
                      ]
                    },
                    {  
                        "id":"12345678-1234-abcd-8910-1234567890ac",
                        "primaryClusterId":"12345678-1234-abcd-8910-1234567890ab",
                        "name":"Gold AWS",
                        "frequencies":[  
                            {  
                                "timeUnit":"Hourly",
                                "frequency":8,
                                "retention":72
                            },
                            {  
                                "timeUnit":"Daily",
                                "frequency":1,
                                "retention":30
                            },
                            {  
                                "timeUnit":"Monthly",
                                "frequency":1,
                                "retention":12
                            },
                            {  
                                "timeUnit":"Yearly",
                                "frequency":1,
                                "retention":2
                            }
                        ]
                    }
                ],
                "total":2
            }'
            return ConvertFrom-Json $response
        }
        It -Name 'should filter on SLA name' -Test {
            ( Get-RubrikSLA -Name 'Gold' ).Name |
                Should -BeExactly 'Gold'
        }
        It -Name 'frequencies array should be populated' -Test {
            ( Get-RubrikSLA -Name 'Gold' ).frequencies.Count |
                Should -BeGreaterThan 0
        }
        It -Name 'hourly frequency set' -Test {
            ((Get-RubrikSLA -Name 'Gold').frequencies -match "Hourly").frequency |
                Should -BeExactly 8
        }
        It -Name 'hourly retention set' -Test {
            ((Get-RubrikSLA -Name 'Gold').frequencies -match "Hourly").retention | 
                Should -BeExactly 72
        }
        It -Name 'daily frequency set' -Test {
            ((Get-RubrikSLA -Name 'Gold').frequencies -match "Daily").frequency | 
                Should -BeExactly 1
        }
        It -Name 'daily retention set' -Test {
            ((Get-RubrikSLA -Name 'Gold').frequencies -match "Daily").retention | 
                Should -BeExactly 30
        }
        It -Name 'weekly frequency set' -Test {
            ((Get-RubrikSLA -Name 'Gold').frequencies -match "Weekly").frequency | 
                Should -BeExactly 1
        }
        It -Name 'weekly retention set' -Test {
            ((Get-RubrikSLA -Name 'Gold').frequencies -match "Weekly").retention | 
                Should -BeExactly 4
        }
        It -Name 'monthly frequency set' -Test {
            ((Get-RubrikSLA -Name 'Gold').frequencies -match "Monthly").frequency | 
                Should -BeExactly 1
        }
        It -Name 'monthly retention set' -Test {
            ((Get-RubrikSLA -Name 'Gold').frequencies -match "Monthly").retention | 
                Should -BeExactly 12
        }
        It -Name 'yearly frequency set' -Test {
            ((Get-RubrikSLA -Name 'Gold').frequencies -match "Yearly").frequency | 
                Should -BeExactly 1
        }
        It -Name 'yearly retention set' -Test {
            ((Get-RubrikSLA -Name 'Gold').frequencies -match "Yearly").retention | 
                Should -BeExactly 2
        }
        Assert-VerifiableMock
        Assert-MockCalled -CommandName Test-RubrikConnection -ModuleName 'Rubrik' -Times 1
        Assert-MockCalled -CommandName Submit-Request -ModuleName 'Rubrik' -Times 1
    }

    Context -Name 'Parameter/Name-v5' {
        $global:rubrikConnection = @{
            id      = 'test-id'
            userId  = 'test-userId'
            token   = 'test-token'
            server  = 'test-server'
            header  = @{ 'Authorization' = 'Bearer test-authorization' }
            time    = (Get-Date)
            api     = 'v5'
            version = '5.0.1'
        }        
        Mock -CommandName Test-RubrikConnection -Verifiable -ModuleName 'Rubrik' -MockWith {}
        Mock -CommandName Submit-Request -Verifiable -ModuleName 'Rubrik' -MockWith {
            $response = '{  
                "hasMore":false,
                "data":[  
                    {
                        "id": "12345678-1234-abcd-8910-1234567890ab",
                        "primaryClusterId": "12345678-1234-abcd-8910-1234567890ab",
                        "name": "Gold",
                        "frequencies": {
                            "hourly": {
                                "frequency": 8,
                                "retention": 72
                              },
                              "daily": {
                                "frequency": 1,
                                "retention": 30
                              },
                              "weekly": {
                                "frequency": 1,
                                "retention": 4,
                                "dayOfWeek": "Saturday"
                              },
                              "monthly": {
                                "dayOfMonth": "LastDay",
                                "frequency": 1,
                                "retention": 12
                              },
                              "yearly": {
                                "yearStartMonth": "March",
                                "dayOfYear": "FirstDay",
                                "frequency": 1,
                                "retention": 2
                              }
                        },
                        "showAdvancedUi": true,
                        "advancedUiConfig": [
                            {
                            "timeUnit": "Hourly",
                            "retentionType": "Daily"
                            },
                            {
                            "timeUnit": "Daily",
                            "retentionType": "Daily"
                            },
                            {
                            "timeUnit": "Weekly",
                            "retentionType": "Weekly"
                            },
                            {
                            "timeUnit": "Monthly",
                            "retentionType": "Quarterly"
                            },
                            {
                            "timeUnit": "Yearly",
                            "retentionType": "Yearly"
                            }
                        ]
                    },
                    {
                        "id": "12345678-1234-abcd-8910-1234567890ac",
                        "primaryClusterId": "12345678-1234-abcd-8910-1234567890ab",
                        "name": "Gold AWS",
                        "frequencies": {
                            "hourly": {
                                "frequency": 8,
                                "retention": 72
                              },
                              "daily": {
                                "frequency": 1,
                                "retention": 30
                              },
                              "weekly": {
                                "frequency": 1,
                                "retention": 4,
                                "dayOfWeek": "Saturday"
                              },
                              "monthly": {
                                "dayOfMonth": "LastDay",
                                "frequency": 1,
                                "retention": 12
                              },
                              "yearly": {
                                "yearStartMonth": "March",
                                "dayOfYear": "FirstDay",
                                "frequency": 1,
                                "retention": 2
                              }
                        },
                        "showAdvancedUi": true,
                        "advancedUiConfig": [
                            {
                            "timeUnit": "Hourly",
                            "retentionType": "Daily"
                            },
                            {
                            "timeUnit": "Daily",
                            "retentionType": "Daily"
                            },
                            {
                            "timeUnit": "Weekly",
                            "retentionType": "Weekly"
                            },
                            {
                            "timeUnit": "Monthly",
                            "retentionType": "Quarterly"
                            },
                            {
                            "timeUnit": "Yearly",
                            "retentionType": "Yearly"
                            }
                        ]
                    }
                ],
                "total":2
            }'
            return ConvertFrom-Json $response
        }
        It -Name 'should filter on SLA name' -Test {
            ( Get-RubrikSLA -Name 'Gold' ).Name |
                Should -BeExactly 'Gold'
        }
        It -Name 'hourly frequency exists' -Test {
            (Get-RubrikSLA -Name 'Gold').frequencies.hourly |
                Should -Not -BeNullOrEmpty
        }
        It -Name 'hourly frequency set' -Test {
            (Get-RubrikSLA -Name 'Gold').frequencies.hourly.frequency | 
                Should -BeExactly 8
        }
        It -Name 'hourly retention set' -Test {
            (Get-RubrikSLA -Name 'Gold').frequencies.hourly.retention | 
                Should -BeExactly 72
        }
        It -Name 'daily frequency exists' -Test {
            (Get-RubrikSLA -Name 'Gold').frequencies.daily | 
                Should -Not -BeNullOrEmpty
        }
        It -Name 'daily frequency set' -Test {
            (Get-RubrikSLA -Name 'Gold').frequencies.daily.frequency | 
                Should -BeExactly 1
        }
        It -Name 'daily retention set' -Test {
            (Get-RubrikSLA -Name 'Gold').frequencies.daily.retention | 
                Should -BeExactly 30
        }
        It -Name 'weekly frequency exists' -Test {
            (Get-RubrikSLA -Name 'Gold').frequencies.weekly | 
                Should -Not -BeNullOrEmpty
        }
        It -Name 'weekly frequency set' -Test {
            (Get-RubrikSLA -Name 'Gold').frequencies.weekly.frequency | 
                Should -BeExactly 1
        }
        It -Name 'weekly retention set' -Test {
            (Get-RubrikSLA -Name 'Gold').frequencies.weekly.retention | 
                Should -BeExactly 4
        }
        It -Name 'monthly frequency exists' -Test {
            (Get-RubrikSLA -Name 'Gold').frequencies.monthly | 
                Should -Not -BeNullOrEmpty
        }
        It -Name 'monthly frequency set' -Test {
            (Get-RubrikSLA -Name 'Gold').frequencies.monthly.frequency | 
                Should -BeExactly 1
        }
        It -Name 'monthly retention set' -Test {
            (Get-RubrikSLA -Name 'Gold').frequencies.monthly.retention | 
                Should -BeExactly 12
        }
        It -Name 'yearly frequency exists' -Test {
            (Get-RubrikSLA -Name 'Gold').frequencies.yearly | 
                Should -Not -BeNullOrEmpty
        }
        It -Name 'yearly frequency set' -Test {
            (Get-RubrikSLA -Name 'Gold').frequencies.yearly.frequency | 
                Should -BeExactly 1
        }
        It -Name 'yearly retention set' -Test {
            (Get-RubrikSLA -Name 'Gold').frequencies.yearly.retention | 
                Should -BeExactly 2
        }     
        Assert-VerifiableMock
        Assert-MockCalled -CommandName Test-RubrikConnection -ModuleName 'Rubrik' -Times 1
        Assert-MockCalled -CommandName Submit-Request -ModuleName 'Rubrik' -Times 1
    }

    Context -Name 'Parameter Validation' {
        It -Name 'Parameter Name cannot be $null' -Test {
            { Get-RubrikSLA -Name $null } |
                Should -Throw "Cannot validate argument on parameter 'Name'"
        }
        It -Name 'Parameter Name cannot be empty' -Test {
            { Get-RubrikSLA -Name '' } |
                Should -Throw "Cannot validate argument on parameter 'Name'"
        }
        It -Name 'Parameter ID cannot be $null' -Test {
            { Get-RubrikSLA -Id $null } |
                Should -Throw "Cannot validate argument on parameter 'ID'"
        }
        It -Name 'Parameter ID cannot be empty' -Test {
            { Get-RubrikSLA -Id '' } |
                Should -Throw "Cannot validate argument on parameter 'ID'"
        }
        It -Name 'Parameters ID and Name cannot be simultaneously used' -Test {
            { Get-RubrikSLA -Id 12345678-1234-abcd-8910-1234567890ab -Name 'Gold' } |
                Should -Throw "Parameter set cannot be resolved using the specified named parameters."
        }
    }
}