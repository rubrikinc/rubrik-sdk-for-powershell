Remove-Module -Name 'Rubrik' -ErrorAction 'SilentlyContinue'
Import-Module -Name './Rubrik/Rubrik.psd1' -Force

foreach ( $privateFunctionFilePath in ( Get-ChildItem -Path './Rubrik/Private' | Where-Object extension -eq '.ps1').FullName  ) {
    . $privateFunctionFilePath
}

Describe -Name 'Public/Get-RubrikAPIToken' -Tag 'Public', 'Get-RubrikAPIToken' -Fixture {
    #region init
    $global:rubrikConnection = @{
        id      = 'test-id'
        userId  = 'test-userId'
        token   = 'test-token'
        server  = 'test-server'
        header  = @{ 'Authorization' = 'Bearer test-authorization' }
        time    = (Get-Date)
        api     = 'v1'
        version = '5.0.0'
    }
    #endregion

    Context -Name 'Results Filtering' {
        Mock -CommandName Test-RubrikConnection -Verifiable -ModuleName 'Rubrik' -MockWith {}
        Mock -CommandName Submit-Request -Verifiable -ModuleName 'Rubrik' -MockWith {
            @{ 
                'id'                     = '11111'
                'userId'                 = '12345'
                'tag'                    = 'roxie'
                'organizationId'         = 'org1'
            },
            @{ 
                'id'                     = '22222'
                'userId'                 = '56789'
                'tag'                    = 'powershell'
                'organizationId'         = 'org1'
            },
            @{ 
                'id'                     = '33333'
                'userId'                 = '12345'
                'tag'                    = 'python'
                'organizationId'         = 'org1'
            },
            @{ 
                'id'                     = '44444'
                'userId'                 = '12345'
                'tag'                    = 'ruby'
                'organizationId'         = 'org2'
            }
        }
        It -Name 'Should Return count of 4' -Test {
            ( Get-RubrikAPIToken).Count |
                Should -BeExactly 4
        }
        It -Name 'Should Return count of 3' -Test {
            (Get-RubrikAPIToken -organizationId 'org1').Count |
                Should -BeExactly 3
        }
        It -Name 'Should Return 11111' -Test {
            ( Get-RubrikAPIToken -Tag 'roxie').id |
                Should -BeExactly '11111'
        }
        It -Name 'Should return count of 0 ' -Test {
            (Get-RubrikAPIToken -Tag 'nonexistant').count |
                Should -BeExactly 0
        }
        It -Name 'Parameter UserID cannot be $null' -Test {
            { Get-RubrikAPIToken -UserId $null } |
                Should -Throw "Cannot validate argument on parameter 'UserId'"
        }
        It -Name 'Parameter UserId cannot be empty' -Test {
            { Get-RubrikAPIToken -UserId '' } |
                Should -Throw "Cannot validate argument on parameter 'UserId'"
        }
        Assert-VerifiableMock
        Assert-MockCalled -CommandName Test-RubrikConnection -ModuleName 'Rubrik' -Times 1
        Assert-MockCalled -CommandName Submit-Request -ModuleName 'Rubrik' -Times 1
    }
}