Remove-Module -Name 'Rubrik' -ErrorAction 'SilentlyContinue'
Import-Module -Name './Rubrik/Rubrik.psd1' -Force

foreach ( $privateFunctionFilePath in ( Get-ChildItem -Path './Rubrik/Private' | Where-Object extension -eq '.ps1').FullName  ) {
    . $privateFunctionFilePath
}

Describe -Name 'Public/Get-RubrikSLAFrequencySummary' -Tag 'Public', 'Get-RubrikSLAFrequencySummary' -Fixture {
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

    Context -Name 'Returned Results' {
        Mock -CommandName Test-RubrikConnection -Verifiable -ModuleName 'Rubrik' -MockWith { }
            $sladomain = '{
                "id":"12345678-1234-abcd-8910-1234567890ab",
                "primaryClusterId":"12345678-1234-abcd-8910-1234567890ab",
                "name":"Gold",
                "frequencies": {
                  "hourly": {
                    "frequency":8,
                    "retention":72
                    },
                  "daily": {
                    "frequency":1,
                    "retention":30
                  },
                  "monthly": {
                  "frequency":1,
                  "retention":12
                  },
                  "yearly": {
                  "frequency":1,
                  "retention":2
                  }
                }
              }'
            $sladomainAdvancedConfig = '{
                "id":"12345678-1234-abcd-8910-1234567890ab",
                "primaryClusterId":"12345678-1234-abcd-8910-1234567890ab",
                "name":"Gold",
                "frequencies": {
                    "hourly": {
                      "frequency": 1,
                      "retention": 1
                    },
                    "daily": {
                      "frequency": 1,
                      "retention": 4
                    },
                    "monthly": {
                      "dayOfMonth": "LastDay",
                      "retention": 1,
                      "frequency": 1
                    },
                    "yearly": {
                      "yearStartMonth": "January",
                      "dayOfYear": "LastDay",
                      "retention": 2,
                      "frequency": 1
                    }
                },
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
                      "timeUnit": "Monthly",
                      "retentionType": "Yearly"
                    },
                    {
                      "timeUnit": "Yearly",
                      "retentionType": "Yearly"
                    }
                  ]
            }'
            $sladomainobj = ConvertFrom-Json $sladomain
            $sladomainobjAdvanced = ConvertFrom-Json $sladomainAdvancedConfig

            It -Name 'Should take non-advanced path in function' -Test {
              $Output = Get-RubrikSLAFrequencySummary -sladomain $sladomainobj -Verbose 4>&1
              (-join $Output) | 
                  Should -BeLike '*No advanced config found*'
            }

            It -Name 'Find proper frequency summary count for non-advanced config' -Test {
                (Get-RubrikSLAFrequencySummary -sladomain $sladomainobj).FrequencySummary.Count |
                    Should -BeExactly 4
            }

            It -Name 'Should take advanced path in function' -Test {
              $Output = Get-RubrikSLAFrequencySummary -sladomain $sladomainobjAdvanced -Verbose 4>&1
              (-join $Output) | 
                  Should -BeLike '*Advanced config found, using this*'
            }

            It -Name 'Find proper frequency summary count for advanced config' -Test {
                (Get-RubrikSLAFrequencySummary -sladomain $sladomainobjAdvanced).FrequencySummary.Count |
                    Should -BeExactly 4
            }
    }
}