Remove-Module -Name 'Rubrik' -ErrorAction 'SilentlyContinue'
Import-Module -Name './Rubrik/Rubrik.psd1' -Force

foreach ( $privateFunctionFilePath in ( Get-ChildItem -Path './Rubrik/Private' | Where-Object extension -eq '.ps1').FullName  ) {
    . $privateFunctionFilePath
}

Describe -Name 'Public/Remove-RubrikReport' -Tag 'Public', 'Remove-RubrikReport' -Fixture {
    Context -Name 'Returning results' {
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
            @{
                Status = 'Success'
                HTTPStatusCode = 204
            }
        }
        It -Name 'Should Return status of Success' -Test {
            ( Remove-RubrikReport -id '12345678-1234-abcd-8910-1234567890ab').Status |
                Should -BeExactly 'Success'
        }

        It -Name 'Should Return HTTP status code 204' -Test {
            ( Remove-RubrikReport -id '12345678-1234-abcd-8910-1234567890ab').HTTPStatusCode |
                Should -BeExactly 204
        }
        Assert-VerifiableMock
        Assert-MockCalled -CommandName Test-RubrikConnection -ModuleName 'Rubrik' -Times 1
        Assert-MockCalled -CommandName Submit-Request -ModuleName 'Rubrik' -Times 1
    }
    Context -Name 'Parameter Validation' {
        It -Name 'Parameter ID cannot be $null or empty' -Test {
            { Remove-RubrikReport -id $null } |
                Should -Throw "Cannot bind argument to parameter 'id' because it is an empty string."
        }
    }
}