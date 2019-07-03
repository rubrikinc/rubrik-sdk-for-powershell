Remove-Module -Name 'Rubrik' -ErrorAction 'SilentlyContinue'
Import-Module -Name './Rubrik/Rubrik.psd1' -Force

foreach ( $privateFunctionFilePath in ( Get-ChildItem -Path './Rubrik/Private' | Where-Object extension -eq '.ps1').FullName  ) {
    . $privateFunctionFilePath
}

Describe -Name 'Public/Export-RubrikDatabase' -Tag 'Public', 'Export-RubrikDatabase' -Fixture {
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
                'id'        = 'RESTORE_MSSQL_DB_databaseid'
                'status'    = 'QUEUED'
                'progress'  = '0'
                'startTime' = '2019-07-02 11:21:22 PM'
            }
        }
        
        Context -Name 'Command Execution' {
            It -Name 'Should return status of queued' -Test {
                (   
                    Export-RubrikDatabase -Id 'databaseid' -RecoveryDateTime 'July 2, 2019 7:42:06 PM' -TargetInstanceId 'instanceId' -TargetDatabaseName 'test').status |
                    Should -BeExactly 'QUEUED'
            }
        }
        
        Context -Name 'Parameter Validation' {
            It -Name 'Parameter id must be specified' -Test {
                { Export-RubrikDatabase -Id  } |
                    Should -Throw "Missing an argument for parameter 'Id'. Specify a parameter of type 'System.String' and try again."
            }
            It -Name 'Parameter id cannot be $null or empty' -Test {
                { Export-RubrikDatabase -Id '' } |
                    Should -Throw "Cannot bind argument to parameter 'Id' because it is an empty string."
            }
            It -Name 'Parameter set cannot be resolved.' -Test {
                { Export-RubrikDatabase -Id '111111' } |
                    Should -Throw "Parameter set cannot be resolved using the specified named parameters."
            } 
            It -Name 'RecoveryDateTime must be a date.' -Test {
                # This test can be updated for Pester 5 release - Wildcards are supported there, currently we use Test-PowerShellSix as a workaround
                # Windows PowerShell: "The string was not recognized as a valid DateTime. There is an unknown word starting at index 6."
                # PowerShell 6      : "The string 'July 2nd' was not recognized as a valid DateTime. There is an unknown word starting at index '6'."
                # Pester v5 Test    : "The string * was not recognized as a valid DateTime. There is an unknown word starting at*6*."
                if (Test-PowerShellSix) {
                    { Export-RubrikDatabase -Id '111111' -recoveryDateTime 'July 2nd' -TargetInstanceId 'instanceid' -TargetDatabaseName 'asdf'} |
                        Should -Throw "The string 'July 2nd' was not recognized as a valid DateTime. There is an unknown word starting at index '6'."
                } else {
                    { Export-RubrikDatabase -Id '111111' -recoveryDateTime 'July 2nd' -TargetInstanceId 'instanceid' -TargetDatabaseName 'asdf'} |
                        Should -Throw "The string was not recognized as a valid DateTime. There is an unknown word starting at index 6."
                }
            }        
        }
        Assert-VerifiableMock
        Assert-MockCalled -CommandName Test-RubrikConnection -ModuleName 'Rubrik' -Times 1
        Assert-MockCalled -CommandName Submit-Request -ModuleName 'Rubrik' -Times 1
    }
}