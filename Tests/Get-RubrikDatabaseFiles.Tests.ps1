Remove-Module -Name 'Rubrik' -ErrorAction 'SilentlyContinue'
Import-Module -Name './Rubrik/Rubrik.psd1' -Force

foreach ( $privateFunctionFilePath in ( Get-ChildItem -Path './Rubrik/Private' | Where-Object extension -eq '.ps1').FullName  ) {
    . $privateFunctionFilePath
}

Describe -Name 'Public/Get-RubrikDatabaseFiles' -Tag 'Public', 'Get-RubrikDatabaseFiles' -Fixture {
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

    Context -Name 'Verify Results' {
        Mock -CommandName Test-RubrikConnection -Verifiable -ModuleName 'Rubrik' -MockWith {}
        Mock -CommandName Submit-Request -Verifiable -ModuleName 'Rubrik' -MockWith {
            $response = '[
                {
                  "logicalName": "AdventureWorks2014_Data",
                  "originalPath": "Z:\\Program Files\\Microsoft SQL Server\\MSSQL12.MSSQLSERVER\\MSSQL\\DATA",
                  "originalName": "AdventureWorks2014_Data.mdf",
                  "fileType": "Data",
                  "fileId": 1
                },
                {
                  "logicalName": "AdventureWorks2014_Log",
                  "originalPath": "Z:\\Program Files\\Microsoft SQL Server\\MSSQL12.MSSQLSERVER\\MSSQL\\DATA",
                  "originalName": "AdventureWorks2014_Log.ldf",
                  "fileType": "Log",
                  "fileId": 2
                }
              ]'
            return ConvertFrom-Json $response
        }
        #Mock -CommandName Test-ReturnFormat -Verifiable -ModuleName 'Rubrik' -MockWith {
        #    param(
        #        $api,
        #        $result,
        #        $localtion
        #    )
        #    $result  
        #}
        
        It -Name 'Should return two results' -Test {
            ( Get-RubrikDatabaseFiles -id 'MssqlDatabase:::12345678-1234-abcd-8910-1234567890ab' -time '2010-01-01T00:00:00.000Z').Count |
                Should -BeExactly 2
        }

        It -Name 'Results match expected values' -Test {
            $results = Get-RubrikDatabaseFiles -id 'MssqlDatabase:::12345678-1234-abcd-8910-1234567890ab' -time '2010-01-01T00:00:00.000Z'
            $results[0].logicalName | Should -BeExactly "AdventureWorks2014_Data"
            $results[1].logicalName | Should -BeExactly "AdventureWorks2014_Log"
            $results[0].originalPath | Should -BeExactly "Z:\Program Files\Microsoft SQL Server\MSSQL12.MSSQLSERVER\MSSQL\DATA"
            $results[1].originalPath | Should -BeExactly "Z:\Program Files\Microsoft SQL Server\MSSQL12.MSSQLSERVER\MSSQL\DATA"
            $results[0].originalName | Should -BeExactly "AdventureWorks2014_Data.mdf"
            $results[1].originalName | Should -BeExactly "AdventureWorks2014_Log.ldf"
            $results[0].fileType | Should -BeExactly "Data"
            $results[1].fileType | Should -BeExactly "Log"
        }

        Assert-VerifiableMock
        Assert-MockCalled -CommandName Test-RubrikConnection -ModuleName 'Rubrik' -Exactly 2
        Assert-MockCalled -CommandName Submit-Request -ModuleName 'Rubrik' -Exactly 2
        #Assert-MockCalled -CommandName Test-ReturnFormat -ModuleName 'Rubrik' -Exactly 2
    }

    Context -Name 'Parameter Validation' {
        It -Name 'Parameter ID cannot be $null' -Test {
            { Get-RubrikDatabaseFiles -Id $null } |
                Should -Throw "Cannot validate argument on parameter 'ID'"
        }
        It -Name 'Parameter ID cannot be empty' -Test {
            { Get-RubrikDatabaseFiles -Id '' } |
                Should -Throw "Cannot validate argument on parameter 'ID'"
        }
        It -Name 'Parameters Time and RecoveryDateTime cannot be simultaneously used' -Test {
            { Get-RubrikDatabaseFiles -time '2010-01-01T00:00:00.000Z' -RecoveryDateTime (Get-Date).AddDays(-1) } |
                Should -Throw "Parameter set cannot be resolved using the specified named parameters."
        }
    }
}