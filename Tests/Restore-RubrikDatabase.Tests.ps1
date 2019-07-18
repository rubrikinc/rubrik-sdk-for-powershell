Remove-Module -Name 'Rubrik' -ErrorAction 'SilentlyContinue'
Import-Module -Name './Rubrik/Rubrik.psd1' -Force

foreach ( $privateFunctionFilePath in ( Get-ChildItem -Path './Rubrik/Private' | Where-Object extension -eq '.ps1').FullName  ) {
    . $privateFunctionFilePath
}

Describe -Name 'Public/Restore-RubrikDatabase' -Tag 'Public', 'Restore-RubrikDatabase' -Fixture {
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
                'id'        = 'RESTORE_MSSQL_DB_01234567-8910-1abc-d435-0abc1234d567_01234567-8910-1abc-d435-0abc1234d567:::0'
                'status'    = 'QUEUED'
                'progress'  = '0'
                'startTime' = '2019-07-02 11:21:22 PM'
            }
        }
        
        It -Name 'Should return status of queued' -Test {
            ( Restore-RubrikDatabase -Id 'MssqlDatabase:::12345678-1234-abcd-8910-1234567890ab' -RecoveryDateTime 'July 2, 2019 11:21:22 PM' -FinishRecovery ).status |
                Should -BeExactly 'QUEUED'
        }

        Assert-VerifiableMock
        Assert-MockCalled -CommandName Test-RubrikConnection -ModuleName 'Rubrik' -Times 1
        Assert-MockCalled -CommandName Submit-Request -ModuleName 'Rubrik' -Times 1
    }

    Context -Name 'Parameter Validation' {
        It -Name 'Parameter ID must be specified' -Test {
            { Restore-RubrikDatabase -Id  } |
                Should -Throw "Missing an argument for parameter 'Id'. Specify a parameter of type 'System.String' and try again."
        }
        It -Name 'Parameter ID cannot be $null or empty' -Test {
            { Restore-RubrikDatabase -Id $null } |
                Should -Throw "Cannot validate argument on parameter 'Id'. The argument is null or empty."
        }
        It -Name 'Parameter ID cannot be empty' -Test {
            { Restore-RubrikDatabase -Id '' } |
                Should -Throw "Cannot validate argument on parameter 'Id'. The argument is null or empty."
        }
        It -Name 'Check for required parameters' -Test {
            { Restore-RubrikDatabase -Id 'MssqlDatabase:::12345678-1234-abcd-8910-1234567890ab' } |
                Should -Throw "Parameter set cannot be resolved using the specified named parameters."
        }
        It -Name 'Parameters TimestampMs and RecoveryDateTime cannot be simultaneously used' -Test {
            { Restore-RubrikDatabase -Id 'MssqlDatabase:::12345678-1234-abcd-8910-1234567890ab' -TimestampMs 1563374327000 -RecoveryDateTime (Get-Date).AddDays(-1) } |
                Should -Throw "Parameter set cannot be resolved using the specified named parameters."
        }
        It -Name 'Parameters TimestampMs and RecoveryLSN cannot be simultaneously used' -Test {
            { Restore-RubrikDatabase -Id 'MssqlDatabase:::12345678-1234-abcd-8910-1234567890ab' -TimestampMs 1563374327000 -RecoveryLSN 34000000025600001 } |
                Should -Throw "Parameter set cannot be resolved using the specified named parameters."
        }
        It -Name 'Parameters RecoveryLSN and RecoveryDateTime cannot be simultaneously used' -Test {
            { Restore-RubrikDatabase -Id 'MssqlDatabase:::12345678-1234-abcd-8910-1234567890ab' -RecoveryLSN 34000000025600001 -RecoveryDateTime (Get-Date).AddDays(-1) } |
                Should -Throw "Parameter set cannot be resolved using the specified named parameters."
        }
        It -Name 'RecoveryDateTime must be a date.' -Test {
            # This test can be updated for Pester 5 release - Wildcards are supported there, currently we use Test-PowerShellSix as a workaround
            # Windows PowerShell: "The string was not recognized as a valid DateTime. There is an unknown word starting at index 6."
            # PowerShell 6      : "The string 'July 2nd' was not recognized as a valid DateTime. There is an unknown word starting at index '6'."
            # Pester v5 Test    : "The string * was not recognized as a valid DateTime. There is an unknown word starting at*6*."
    
            if (Test-PowerShellSix) {
                { Restore-RubrikDatabase -Id '111111' -recoveryDateTime 'July 2nd' } |
                    Should -Throw "The string 'July 2nd' was not recognized as a valid DateTime. There is an unknown word starting at index '6'."
            } else {
                { Restore-RubrikDatabase -Id '111111' -recoveryDateTime 'July 2nd' } |
                    Should -Throw "The string was not recognized as a valid DateTime. There is an unknown word starting at index 6."
            }
        }        
    }
}