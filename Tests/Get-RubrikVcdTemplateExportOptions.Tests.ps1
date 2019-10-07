Remove-Module -Name 'Rubrik' -ErrorAction 'SilentlyContinue'
Import-Module -Name './Rubrik/Rubrik.psd1' -Force

foreach ( $privateFunctionFilePath in ( Get-ChildItem -Path './Rubrik/Private' | Where-Object extension -eq '.ps1').FullName  ) {
    . $privateFunctionFilePath
}

Describe -Name 'Public/Get-RubrikVcdTemplateExportOptions' -Tag 'Public', 'Get-RubrikVcdTemplateExportOptions' -Fixture {
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

    Context -Name 'Test Export Options' {
        Mock -CommandName Test-RubrikConnection -Verifiable -ModuleName 'Rubrik' -MockWith {}
        Mock -CommandName Submit-Request -Verifiable -ModuleName 'Rubrik' -MockWith {
            $exportoptsjson = '{
                "originalVdcExportOptions": {
                  "orgVdcId": "01234567-8910-1abc-d435-0abc1234d567",
                  "availableStoragePolicies": [
                    {
                      "name": "Storage Policy",
                      "id": "01234567-8910-1abc-d435-0abc1234d567"
                    }
                  ]
                },
                "defaultCatalogExportOptions": {
                  "orgVdcId": "01234567-8910-1abc-d435-0abc1234d567",
                  "availableStoragePolicies": [
                    {
                      "name": "Storage Policy",
                      "id": "01234567-8910-1abc-d435-0abc1234d567"
                    }
                  ]
                }
              }'
            return ConvertFrom-Json -InputObject $exportoptsjson 
        }

        It -Name 'Expected results returned' -Test {
            $result = Get-RubrikVcdTemplateExportOptions -id '01234567-8910-1abc-d435-0abc1234d567' -catalogid 'VcdCatalog:::01234567-8910-1abc-d435-0abc1234d567' -name 'Template-Export'
            $result.originalVdcExportOptions.orgVdcId | Should -BeExactly '01234567-8910-1abc-d435-0abc1234d567'
            $result.defaultCatalogExportOptions.orgVdcId | Should -BeExactly '01234567-8910-1abc-d435-0abc1234d567'
        }
        
        Assert-VerifiableMock
        Assert-MockCalled -CommandName Test-RubrikConnection -ModuleName 'Rubrik' -Times 1
        Assert-MockCalled -CommandName Submit-Request -ModuleName 'Rubrik' -Times 1
    }
    Context -Name 'Test Advanced Export Options' {
        Mock -CommandName Test-RubrikConnection -Verifiable -ModuleName 'Rubrik' -MockWith {}
        Mock -CommandName Submit-Request -Verifiable -ModuleName 'Rubrik' -MockWith {
            $exportoptsjson = '{
                "advancedExportOptions": {
                  "orgVdcId": "01234567-8910-1abc-d435-0abc1234d567",
                  "availableStoragePolicies": [
                    {
                      "name": "Storage Policy",
                      "id": "01234567-8910-1abc-d435-0abc1234d567"
                    }
                  ]
                }
            }'
            return ConvertFrom-Json -InputObject $exportoptsjson 
        }

        It -Name 'Expected results returned' -Test {
            $result = Get-RubrikVcdTemplateExportOptions -id '01234567-8910-1abc-d435-0abc1234d567' -catalogid 'VcdCatalog:::01234567-8910-1abc-d435-0abc1234d567' -orgvdcid 'VcdOrgVdc:::665f23c6-1fc3-4d49-bb58-5841b0c20818' -name 'Template-Export'
            $result.advancedExportOptions.orgVdcId | Should -BeExactly '01234567-8910-1abc-d435-0abc1234d567'
        }
        
        Assert-VerifiableMock
        Assert-MockCalled -CommandName Test-RubrikConnection -ModuleName 'Rubrik' -Times 1
        Assert-MockCalled -CommandName Submit-Request -ModuleName 'Rubrik' -Times 1
    }
    Context -Name 'Test Export Options with Name parameter missing' {
        Mock -CommandName Test-RubrikConnection -Verifiable -ModuleName 'Rubrik' -MockWith {}
        Mock -CommandName Get-RubrikVAppSnapshot -Verifiable -ModuleName 'Rubrik' -MockWith {
            return @{vappName = 'Template'}
        }
        Mock -CommandName Get-RubrikVApp -Verifiable -ModuleName 'Rubrik' -MockWith {
            return @{name = 'Template'}
        }
        Mock -CommandName Submit-Request -Verifiable -ModuleName 'Rubrik' -MockWith {
            $exportoptsjson = '{
                "originalVdcExportOptions": {
                  "orgVdcId": "01234567-8910-1abc-d435-0abc1234d567",
                  "availableStoragePolicies": [
                    {
                      "name": "Storage Policy",
                      "id": "01234567-8910-1abc-d435-0abc1234d567"
                    }
                  ]
                },
                "defaultCatalogExportOptions": {
                  "orgVdcId": "01234567-8910-1abc-d435-0abc1234d567",
                  "availableStoragePolicies": [
                    {
                      "name": "Storage Policy",
                      "id": "01234567-8910-1abc-d435-0abc1234d567"
                    }
                  ]
                }
              }'
            return ConvertFrom-Json -InputObject $exportoptsjson 
        }

        It -Name 'Expected results returned' -Test {
            $result = Get-RubrikVcdTemplateExportOptions -id '01234567-8910-1abc-d435-0abc1234d567' -catalogid 'VcdCatalog:::01234567-8910-1abc-d435-0abc1234d567'
            $result.originalVdcExportOptions.orgVdcId | Should -BeExactly '01234567-8910-1abc-d435-0abc1234d567'
            $result.defaultCatalogExportOptions.orgVdcId | Should -BeExactly '01234567-8910-1abc-d435-0abc1234d567'
        }
        
        Assert-VerifiableMock
        Assert-MockCalled -CommandName Test-RubrikConnection -ModuleName 'Rubrik' -Times 1
        Assert-MockCalled -CommandName Get-RubrikVAppSnapshot -ModuleName 'Rubrik' -Times 1
        Assert-MockCalled -CommandName Get-RubrikVApp -ModuleName 'Rubrik' -Times 1
        Assert-MockCalled -CommandName Submit-Request -ModuleName 'Rubrik' -Times 1
    }
    Context -Name 'Parameter Validation' {
        It -Name 'Parameter ID cannot be null' -Test {
           { Get-RubrikVcdTemplateExportOptions -id $null } |
                Should -Throw "Cannot validate argument on parameter 'id'. The argument is null or empty. Provide an argument that is not null or empty, and then try the command again."
        } 
        It -Name 'Parameter ID cannot be empty' -Test {
            { Get-RubrikVcdTemplateExportOptions -id '' } |
                Should -Throw "Cannot validate argument on parameter 'id'. The argument is null or empty. Provide an argument that is not null or empty, and then try the command again."
        }
    }
}