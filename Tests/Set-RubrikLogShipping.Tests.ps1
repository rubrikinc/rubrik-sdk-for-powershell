Remove-Module -Name 'Rubrik' -ErrorAction 'SilentlyContinue'
Import-Module -Name './Rubrik/Rubrik.psd1' -Force

foreach ( $privateFunctionFilePath in ( Get-ChildItem -Path './Rubrik/Private' | Where-Object extension -eq '.ps1').FullName  ) {
    . $privateFunctionFilePath
}

Describe -Name 'Public/Set-RubrikLogShipping' -Tag 'Public', 'Set-RubrikLogShipping' -Fixture {
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

    Context -Name 'Request Succeeds' {
        Mock -CommandName Test-RubrikConnection -Verifiable -ModuleName 'Rubrik' -MockWith {}
        Mock -CommandName Submit-Request -Verifiable -ModuleName 'Rubrik' -MockWith {
            @{ 
                'id'       = 'MSSQL_APPLY_LOGS_11111'
                'status'   = 'QUEUED'
                'progress' = '0'
            }
        }
        It -Name 'Should return status of QUEUED' -Test {
            ( Set-RubrikLogShipping -id '111111' -state STANDBY).status |
                Should -BeExactly 'QUEUED'
        }
        It -Name 'Should return correct id' -Test {
            ( Set-RubrikLogShipping -id '111111' -state STANDBY).id |
                Should -BeExactly 'MSSQL_APPLY_LOGS_11111'
        }
        It -Name 'Should return correct progress' -Test {
            ( Set-RubrikLogShipping -id '111111' -state STANDBY).progress |
                Should -BeExactly '0'
        }
        Assert-VerifiableMock
        Assert-MockCalled -CommandName Test-RubrikConnection -ModuleName 'Rubrik' -Times 1
        Assert-MockCalled -CommandName Submit-Request -ModuleName 'Rubrik' -Times 1
    }

    Context -Name 'Parameter Validation' {
        It -Name 'Parameter ID cannot be null' -Test {
           { Set-RubrikLogShipping -id $null } |
                Should -Throw "Cannot bind argument to parameter 'id' because it is an empty string."
        } 
        It -Name 'Parameter ID cannot be empty' -Test {
            { Set-RubrikLogShipping -id '' } |
                Should -Throw "Cannot bind argument to parameter 'id' because it is an empty string."
        }
        It -Name 'Validate parameter set state' -Test {
            { Set-RubrikLogShipping -id '1111' -state 'nonexistant' } |
                Should -Throw 'Cannot validate argument on parameter ''state''. The argument "nonexistant" does not belong to the set "RESTORING,STANDBY" specified by the ValidateSet attribute.'
        }
    }
}