Remove-Module -Name 'Rubrik' -ErrorAction 'SilentlyContinue'
Import-Module -Name './Rubrik/Rubrik.psd1' -Force

foreach ( $privateFunctionFilePath in ( Get-ChildItem -Path './Rubrik/Private' | Where-Object extension -eq '.ps1').FullName  ) {
    . $privateFunctionFilePath
}

Describe -Name 'Public/Reset-RubrikLogShipping' -Tag 'Public', 'Reset-RubrikLogShipping' -Fixture {
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
                'id'       = 'RESTORE_MSSQL_DB_11111'
                'status'   = 'QUEUED'
                'progress' = '0'
            }
        }
        It -Name 'Should return status of QUEUED' -Test {
            ( Reset-RubrikLogShipping -id '111111' -state STANDBY).status |
                Should -BeExactly 'QUEUED'
        }
        Assert-VerifiableMock
        Assert-MockCalled -CommandName Test-RubrikConnection -ModuleName 'Rubrik' -Times 1
        Assert-MockCalled -CommandName Submit-Request -ModuleName 'Rubrik' -Times 1
    }

    Context -Name 'Parameter Validation' {
        It -Name 'Parameter ID cannot be null' -Test {
           { Reset-RubrikLogShipping -id $null } |
                Should -Throw "Cannot bind argument to parameter 'id' because it is an empty string."
        } 
        It -Name 'Parameter ID cannot be empty' -Test {
            { Reset-RubrikLogShipping -id '' } |
                Should -Throw "Cannot bind argument to parameter 'id' because it is an empty string."
        }
        It -Name 'Validate parameter set state' -Test {
            { Reset-RubrikLogShipping -id '1111' -state 'nonexistant' } |
                Should -Throw 'Cannot validate argument on parameter ''state''. The argument "nonexistant" does not belong to the set "RESTORING,STANDBY" specified by the ValidateSet attribute.'
        }
    }
}