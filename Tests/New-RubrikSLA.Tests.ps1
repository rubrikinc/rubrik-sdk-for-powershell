Remove-Module -Name 'Rubrik' -ErrorAction 'SilentlyContinue'
Import-Module -Name './Rubrik/Rubrik.psd1' -Force

foreach ( $privateFunctionFilePath in ( Get-ChildItem -Path './Rubrik/Private' | Where-Object extension -eq '.ps1').FullName  ) {
    . $privateFunctionFilePath
}

Describe -Name 'Public/New-RubrikSLA' -Tag 'Public', 'New-RubrikSLA' -Fixture {
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
                "id": "12345678-1234-abcd-8910-1234567890ab",
                "primaryClusterId": "12345678-1234-abcd-8910-1234567890ab",
                "name": "Gold",
                "frequencies": [
                  {
                    "timeUnit": "Hourly",
                    "frequency": 8,
                    "retention": 72
                  },
                  {
                    "timeUnit": "Daily",
                    "frequency": 1,
                    "retention": 30
                  },
                  {
                    "timeUnit": "Weekly",
                    "frequency": 1,
                    "retention": 4
                  },                  
                  {
                    "timeUnit": "Monthly",
                    "frequency": 1,
                    "retention": 12
                  },
                  {
                    "timeUnit": "Yearly",
                    "frequency": 1,
                    "retention": 2
                  }
                ],
                "allowedBackupWindows": [
                  {
                    "startTimeAttributes": {
                      "minutes": 0,
                      "hour": 0,
                      "dayOfWeek": 1
                    },
                    "durationInHours": 1
                  }
                ],
                "firstFullAllowedBackupWindows": [],
                "maxLocalRetentionLimit": 63072000,
                "archivalSpecs": [],
                "replicationSpecs": []
            }'
            return ConvertFrom-Json $response
        }
        It -Name 'frequencies array should be populated' -Test {
            $response = New-RubrikSLA -Name 'Gold' -HourlyFrequency 8 -HourlyRetention 72 -DailyFrequency 1 -DailyRetention 30 -MonthlyFrequency 1 -MonthlyRetention 12 -YearlyFrequency 1 -YearlyRetention 2
            $response.frequencies.count | Should -BeGreaterThan 0
        }
        It -Name 'hourly frequency set' -Test {
            $response = New-RubrikSLA -Name 'Gold' -HourlyFrequency 8 -HourlyRetention 72 -DailyFrequency 1 -DailyRetention 30 -MonthlyFrequency 1 -MonthlyRetention 12 -YearlyFrequency 1 -YearlyRetention 2
            ($response.frequencies -match "Hourly").frequency | Should -BeExactly 8
        }
        It -Name 'hourly retention set' -Test {
            $response = New-RubrikSLA -Name 'Gold' -HourlyFrequency 8 -HourlyRetention 72 -DailyFrequency 1 -DailyRetention 30 -MonthlyFrequency 1 -MonthlyRetention 12 -YearlyFrequency 1 -YearlyRetention 2
            ($response.frequencies -match "Hourly").retention | Should -BeExactly 72
        }
        It -Name 'daily frequency set' -Test {
            $response = New-RubrikSLA -Name 'Gold' -HourlyFrequency 8 -HourlyRetention 72 -DailyFrequency 1 -DailyRetention 30 -MonthlyFrequency 1 -MonthlyRetention 12 -YearlyFrequency 1 -YearlyRetention 2
            ($response.frequencies -match "Daily").frequency | Should -BeExactly 1
        }
        It -Name 'daily retention set' -Test {
            $response = New-RubrikSLA -Name 'Gold' -HourlyFrequency 8 -HourlyRetention 72 -DailyFrequency 1 -DailyRetention 30 -MonthlyFrequency 1 -MonthlyRetention 12 -YearlyFrequency 1 -YearlyRetention 2
            ($response.frequencies -match "Daily").retention | Should -BeExactly 30
        }
        It -Name 'weekly frequency set' -Test {
            $response = New-RubrikSLA -Name 'Gold' -HourlyFrequency 8 -HourlyRetention 72 -DailyFrequency 1 -DailyRetention 30 -MonthlyFrequency 1 -MonthlyRetention 12 -YearlyFrequency 1 -YearlyRetention 2
            ($response.frequencies -match "Weekly").frequency | Should -BeExactly 1
        }
        It -Name 'weekly retention set' -Test {
            $response = New-RubrikSLA -Name 'Gold' -HourlyFrequency 8 -HourlyRetention 72 -DailyFrequency 1 -DailyRetention 30 -MonthlyFrequency 1 -MonthlyRetention 12 -YearlyFrequency 1 -YearlyRetention 2
            ($response.frequencies -match "Weekly").retention | Should -BeExactly 4
        }
        It -Name 'monthly frequency set' -Test {
            $response = New-RubrikSLA -Name 'Gold' -HourlyFrequency 8 -HourlyRetention 72 -DailyFrequency 1 -DailyRetention 30 -MonthlyFrequency 1 -MonthlyRetention 12 -YearlyFrequency 1 -YearlyRetention 2
            ($response.frequencies -match "Monthly").frequency | Should -BeExactly 1
        }
        It -Name 'monthly retention set' -Test {
            $response = New-RubrikSLA -Name 'Gold' -HourlyFrequency 8 -HourlyRetention 72 -DailyFrequency 1 -DailyRetention 30 -MonthlyFrequency 1 -MonthlyRetention 12 -YearlyFrequency 1 -YearlyRetention 2
            ($response.frequencies -match "Monthly").retention | Should -BeExactly 12
        }
        It -Name 'yearly frequency set' -Test {
            $response = New-RubrikSLA -Name 'Gold' -HourlyFrequency 8 -HourlyRetention 72 -DailyFrequency 1 -DailyRetention 30 -MonthlyFrequency 1 -MonthlyRetention 12 -YearlyFrequency 1 -YearlyRetention 2
            ($response.frequencies -match "Yearly").frequency | Should -BeExactly 1
        }
        It -Name 'yearly retention set' -Test {
            $response = New-RubrikSLA -Name 'Gold' -HourlyFrequency 8 -HourlyRetention 72 -DailyFrequency 1 -DailyRetention 30 -MonthlyFrequency 1 -MonthlyRetention 12 -YearlyFrequency 1 -YearlyRetention 2
            ($response.frequencies -match "Yearly").retention | Should -BeExactly 2
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
                "allowedBackupWindows": [
                  {
                    "startTimeAttributes": {
                      "minutes": 0,
                      "hour": 0,
                      "dayOfWeek": 1
                    },
                    "durationInHours": 1
                  }
                ],
                "firstFullAllowedBackupWindows": [],
                "maxLocalRetentionLimit": 157680000,
                "archivalSpecs": [],
                "replicationSpecs": [],
                "isDefault": false,
                "uiColor": "#179995",
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
            }'
            return ConvertFrom-Json $response
        }
        It -Name 'hourly frequency exists' -Test {
            $response = New-RubrikSLA -Name 'Gold' -HourlyFrequency 8 -HourlyRetention 72 -DailyFrequency 1 -DailyRetention 30 -MonthlyFrequency 1 -MonthlyRetention 12 -YearlyFrequency 1 -YearlyRetention 2
            $response.frequencies.hourly | Should -Not -BeNullOrEmpty
        }
        It -Name 'hourly frequency set' -Test {
            $response = New-RubrikSLA -Name 'Gold' -HourlyFrequency 8 -HourlyRetention 72 -DailyFrequency 1 -DailyRetention 30 -MonthlyFrequency 1 -MonthlyRetention 12 -YearlyFrequency 1 -YearlyRetention 2
            $response.frequencies.hourly.frequency | Should -BeExactly 8
        }
        It -Name 'hourly retention set' -Test {
            $response = New-RubrikSLA -Name 'Gold' -HourlyFrequency 8 -HourlyRetention 72 -DailyFrequency 1 -DailyRetention 30 -MonthlyFrequency 1 -MonthlyRetention 12 -YearlyFrequency 1 -YearlyRetention 2
            $response.frequencies.hourly.retention | Should -BeExactly 72
        }
        It -Name 'daily frequency exists' -Test {
            $response = New-RubrikSLA -Name 'Gold' -HourlyFrequency 8 -HourlyRetention 72 -DailyFrequency 1 -DailyRetention 30 -MonthlyFrequency 1 -MonthlyRetention 12 -YearlyFrequency 1 -YearlyRetention 2
            $response.frequencies.daily | Should -Not -BeNullOrEmpty
        }
        It -Name 'daily frequency set' -Test {
            $response = New-RubrikSLA -Name 'Gold' -HourlyFrequency 8 -HourlyRetention 72 -DailyFrequency 1 -DailyRetention 30 -MonthlyFrequency 1 -MonthlyRetention 12 -YearlyFrequency 1 -YearlyRetention 2
            $response.frequencies.daily.frequency | Should -BeExactly 1
        }
        It -Name 'daily retention set' -Test {
            $response = New-RubrikSLA -Name 'Gold' -HourlyFrequency 8 -HourlyRetention 72 -DailyFrequency 1 -DailyRetention 30 -MonthlyFrequency 1 -MonthlyRetention 12 -YearlyFrequency 1 -YearlyRetention 2
            $response.frequencies.daily.retention | Should -BeExactly 30
        }
        It -Name 'weekly frequency exists' -Test {
            $response = New-RubrikSLA -Name 'Gold' -HourlyFrequency 8 -HourlyRetention 72 -DailyFrequency 1 -DailyRetention 30 -MonthlyFrequency 1 -MonthlyRetention 12 -YearlyFrequency 1 -YearlyRetention 2
            $response.frequencies.weekly | Should -Not -BeNullOrEmpty
        }
        It -Name 'weekly frequency set' -Test {
            $response = New-RubrikSLA -Name 'Gold' -HourlyFrequency 8 -HourlyRetention 72 -DailyFrequency 1 -DailyRetention 30 -MonthlyFrequency 1 -MonthlyRetention 12 -YearlyFrequency 1 -YearlyRetention 2
            $response.frequencies.weekly.frequency | Should -BeExactly 1
        }
        It -Name 'weekly retention set' -Test {
            $response = New-RubrikSLA -Name 'Gold' -HourlyFrequency 8 -HourlyRetention 72 -DailyFrequency 1 -DailyRetention 30 -MonthlyFrequency 1 -MonthlyRetention 12 -YearlyFrequency 1 -YearlyRetention 2
            $response.frequencies.weekly.retention | Should -BeExactly 4
        }
        It -Name 'monthly frequency exists' -Test {
            $response = New-RubrikSLA -Name 'Gold' -HourlyFrequency 8 -HourlyRetention 72 -DailyFrequency 1 -DailyRetention 30 -MonthlyFrequency 1 -MonthlyRetention 12 -YearlyFrequency 1 -YearlyRetention 2
            $response.frequencies.monthly | Should -Not -BeNullOrEmpty
        }
        It -Name 'monthly frequency set' -Test {
            $response = New-RubrikSLA -Name 'Gold' -HourlyFrequency 8 -HourlyRetention 72 -DailyFrequency 1 -DailyRetention 30 -MonthlyFrequency 1 -MonthlyRetention 12 -YearlyFrequency 1 -YearlyRetention 2
            $response.frequencies.monthly.frequency | Should -BeExactly 1
        }
        It -Name 'monthly retention set' -Test {
            $response = New-RubrikSLA -Name 'Gold' -HourlyFrequency 8 -HourlyRetention 72 -DailyFrequency 1 -DailyRetention 30 -MonthlyFrequency 1 -MonthlyRetention 12 -YearlyFrequency 1 -YearlyRetention 2
            $response.frequencies.monthly.retention | Should -BeExactly 12
        }
        It -Name 'yearly frequency exists' -Test {
            $response = New-RubrikSLA -Name 'Gold' -HourlyFrequency 8 -HourlyRetention 72 -DailyFrequency 1 -DailyRetention 30 -MonthlyFrequency 1 -MonthlyRetention 12 -YearlyFrequency 1 -YearlyRetention 2
            $response.frequencies.yearly | Should -Not -BeNullOrEmpty
        }
        It -Name 'yearly frequency set' -Test {
            $response = New-RubrikSLA -Name 'Gold' -HourlyFrequency 8 -HourlyRetention 72 -DailyFrequency 1 -DailyRetention 30 -MonthlyFrequency 1 -MonthlyRetention 12 -YearlyFrequency 1 -YearlyRetention 2
            $response.frequencies.yearly.frequency | Should -BeExactly 1
        }
        It -Name 'yearly retention set' -Test {
            $response = New-RubrikSLA -Name 'Gold' -HourlyFrequency 8 -HourlyRetention 72 -DailyFrequency 1 -DailyRetention 30 -MonthlyFrequency 1 -MonthlyRetention 12 -YearlyFrequency 1 -YearlyRetention 2
            $response.frequencies.yearly.retention | Should -BeExactly 2
        }
        Assert-VerifiableMock
        Assert-MockCalled -CommandName Test-RubrikConnection -ModuleName 'Rubrik' -Times 1
        Assert-MockCalled -CommandName Submit-Request -ModuleName 'Rubrik' -Times 1
    }

    Context -Name 'Parameter Validation' {
        It -Name 'Parameter Name cannot be $null' -Test {
            { New-RubrikSLA -Name $null } |
                Should -Throw "Cannot validate argument on parameter 'Name'"
        }
        It -Name 'Parameter Name cannot be empty' -Test {
            { New-RubrikSLA -Name '' } |
                Should -Throw "Cannot validate argument on parameter 'Name'"
        }
        It -Name 'SLA Paramters cannot be empty' -Test {
            { New-RubrikSLA -Name 'Gold'} |
                Should -Throw "You did not specify any frequency and retention values"
        }
    }
}