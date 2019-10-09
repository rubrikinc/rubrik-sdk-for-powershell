Remove-Module -Name 'Rubrik' -ErrorAction 'SilentlyContinue'
Import-Module -Name './Rubrik/Rubrik.psd1' -Force

foreach ( $privateFunctionFilePath in ( Get-ChildItem -Path './Rubrik/Private' | Where-Object extension -eq '.ps1').FullName  ) {
    . $privateFunctionFilePath
}

Describe -Name 'Public/Remove-RubrikOrganization' -Tag 'Public', 'Remove-RubrikOrganization' -Fixture {
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

    Context -Name 'Parameters' {
        Mock -CommandName Test-RubrikConnection -Verifiable -ModuleName 'Rubrik' -MockWith {}
        Mock -CommandName Submit-Request -Verifiable -ModuleName 'Rubrik' -MockWith {
            @{
                Status = 'Success'
                HTTPStatusCode = 204
            }
        }
        It -Name 'Should Return status of Success' -Test {
            ( Remove-RubrikOrganization -id '01234567-8910-1abc-d435-0abc1234d567').Status |
                Should -BeExactly 'Success'
        }

        It -Name 'Should Return HTTP status code 204' -Test {
            ( Remove-RubrikOrganization -id '01234567-8910-1abc-d435-0abc1234d567').HTTPStatusCode |
                Should -BeExactly 204
        }

        Assert-VerifiableMock
        Assert-MockCalled -CommandName Test-RubrikConnection -ModuleName 'Rubrik' -Exactly 2
        Assert-MockCalled -CommandName Submit-Request -ModuleName 'Rubrik' -Exactly 2
    }
    
    Context -Name 'Parameter Validation' {
        It -Name 'Parameter id cannot be $null' -Test {
            { Remove-RubrikOrganization -id $null } |
                Should -Throw "Cannot validate argument on parameter 'id'. The argument is null or empty."
        }
        It -Name 'Parameter id cannot be empty' -Test {
            { Remove-RubrikOrganization -id '' } |
                Should -Throw "Cannot validate argument on parameter 'id'. The argument is null or empty."
        }
    }
}