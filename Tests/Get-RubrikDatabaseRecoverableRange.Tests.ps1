Remove-Module -Name 'Rubrik' -ErrorAction 'SilentlyContinue'
Import-Module -Name './Rubrik/Rubrik.psd1' -Force

foreach ( $privateFunctionFilePath in ( Get-ChildItem -Path './Rubrik/Private' | Where-Object extension -eq '.ps1').FullName  ) {
    . $privateFunctionFilePath
}

Describe -Name 'Public/Get-RubrikDatabaseRecoverableRange' -Tag 'Public', 'Get-RubrikDatabaseRecoverableRange' -Fixture {
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
                    "beginTime": "2019-01-01T01:00:00.000Z",
                    "endTime": "2019-01-01T01:00:00.000Z",
                    "status": "OK",
                    "isMountAllowed": true
                  },
                  {
                    "beginTime": "2019-01-02T01:00:00.000Z",
                    "endTime": "2019-01-02T01:00:00.000Z",
                    "status": "OK",
                    "isMountAllowed": true
                  },
                  {
                    "beginTime": "2019-01-03T01:00:00.000Z",
                    "endTime": "2019-01-03T01:00:00.000Z",
                    "status": "OK",
                    "isMountAllowed": true
                  }
                ],
                "total": 3
              }'
            return ConvertFrom-Json $response
        }
        It -Name 'Query based on ID' -Test {
            ( Get-RubrikDatabaseRecoverableRange -id 'MssqlDatabase:::12345678-1234-abcd-8910-1234567890ab' ).Count |
                Should -BeExactly 3
        }
        Assert-VerifiableMock
        Assert-MockCalled -CommandName Test-RubrikConnection -ModuleName 'Rubrik' -Times 1
        Assert-MockCalled -CommandName Submit-Request -ModuleName 'Rubrik' -Times 1
    }

    Context -Name 'Single Result' {
        Mock -CommandName Test-RubrikConnection -Verifiable -ModuleName 'Rubrik' -MockWith {}
        Mock -CommandName Submit-Request -Verifiable -ModuleName 'Rubrik' -MockWith {
            $response = '{
                "hasMore": false,
                "data": [
                    {
                      "beginTime": "{0}",
                      "endTime": "{0}",
                      "status": "OK",
                      "isMountAllowed": true
                    }
                ],
                "total": 1
              }' -replace '\{0\}', (Get-Date -Year 2019 -Month 1 -Day 2).Date
            return ConvertFrom-Json $response
        }
        It -Name 'Query based on ID and time range' -Test {
            @( Get-RubrikDatabaseRecoverableRange -id 'MssqlDatabase:::12345678-1234-abcd-8910-1234567890ab' -BeforeTime '2019-01-03T01:00:00.000Z' -AfterTime '2019-01-01T01:00:00.000Z' ).Count |
                Should -BeExactly 1
        }
        It -Name 'Results match expected values' -Test {
            $results = Get-RubrikDatabaseRecoverableRange -id 'MssqlDatabase:::12345678-1234-abcd-8910-1234567890ab' -BeforeTime '2019-01-03T01:00:00.000Z' -AfterTime '2019-01-01T01:00:00.000Z'
            ($results.beginTime -as [datetime]).ToString('yyyy-MM-ddTHH:mm:ssZ') | Should -BeExactly '2019-01-02T00:00:00Z'
            ($results.endTime -as [datetime]).ToString('yyyy-MM-ddTHH:mm:ssZ') | Should -BeExactly '2019-01-02T00:00:00Z'
            $results.status | Should -BeExactly 'OK'
            $results.isMountAllowed | Should -BeExactly $true
        }
        Assert-VerifiableMock
        Assert-MockCalled -CommandName Test-RubrikConnection -ModuleName 'Rubrik' -Times 1
        Assert-MockCalled -CommandName Submit-Request -ModuleName 'Rubrik' -Times 1
    }

    Context -Name 'Parameter Validation' {
        It -Name 'Parameter ID cannot be $null' -Test {
            { Get-RubrikDatabaseRecoverableRange -Id $null } |
                Should -Throw "Cannot validate argument on parameter 'ID'"
        }
        It -Name 'Parameter ID cannot be empty' -Test {
            { Get-RubrikDatabaseRecoverableRange -Id '' } |
                Should -Throw "Cannot validate argument on parameter 'ID'"
        }
    }
}