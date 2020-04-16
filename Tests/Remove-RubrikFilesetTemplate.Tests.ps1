Remove-Module -Name 'Rubrik' -ErrorAction 'SilentlyContinue'
Import-Module -Name './Rubrik/Rubrik.psd1' -Force

foreach ( $privateFunctionFilePath in ( Get-ChildItem -Path './Rubrik/Private' | Where-Object extension -eq '.ps1').FullName  ) {
    . $privateFunctionFilePath
}

Describe -Name 'Public/Remove-RubrikFilesetTemplate' -Tag 'Public', 'Remove-RubrikFilesetTemplate' -Fixture {
    #region init
    $global:rubrikConnection = @{
        id      = 'test-id'
        userId  = 'test-userId'
        token   = 'test-token'
        server  = 'test-server'
        header  = @{ 'Authorization' = 'Bearer test-authorization' }
        time    = (Get-Date)
        api     = 'v1'
        version = '4.0'
    }
    #endregion

    Context -Name 'Returned Results' {
        Mock -CommandName Test-RubrikConnection -Verifiable -ModuleName 'Rubrik' -MockWith {}
        Mock -CommandName Submit-Request -Verifiable -ModuleName 'Rubrik' -MockWith {
            @{
                Status = 'Success'
                HTTPStatusCode = 204
            }
        }
        It -Name 'HTTPStatusCode is correct' -Test {
            ( Remove-RubrikFilesetTemplate -id 'filesetid').HTTPStatusCode  |
                Should -BeExactly 204
        }

        Mock -CommandName Submit-Request -Verifiable -ModuleName 'Rubrik' -MockWith {
            @{
                Status = 'Success'
                HTTPStatusCode = 205
            }
        }
        It -Name 'Correctly Detects incorrect HTTP Status Code' -Test {
            ( Remove-RubrikFilesetTemplate -id 'filesetid').HTTPStatusCode  |
                Should -Not -Be 204
        }

        Assert-VerifiableMock
        Assert-MockCalled -CommandName Test-RubrikConnection -ModuleName 'Rubrik' -Exactly 2
        Assert-MockCalled -CommandName Submit-Request -ModuleName 'Rubrik' -Exactly 2
    }
    Context -Name 'Parameter Validation' {
        It -Name 'Parameter id cannot be $null' -Test {
            { Remove-RubrikFilesetTemplate -id $null } |
                Should -Throw "Cannot bind argument to parameter 'id' because it is an empty string."
        }
        It -Name 'Parameter id missing' -Test {
            { Remove-RubrikFilesetTemplate -id '' } |
                Should -Throw "Cannot bind argument to parameter 'id' because it is an empty string."
        }
    }
}