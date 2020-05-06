Remove-Module -Name 'Rubrik' -ErrorAction 'SilentlyContinue'
Import-Module -Name './Rubrik/Rubrik.psd1' -Force

foreach ( $privateFunctionFilePath in ( Get-ChildItem -Path './Rubrik/Private' | Where-Object extension -eq '.ps1').FullName  ) {
    . $privateFunctionFilePath
}

Describe -Name 'Public/Set-RubrikAvailabilityGroup' -Tag 'Public', 'Set-RubrikAvailabilityGroup' -Fixture {
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
 
    Context -Name 'Results Filtering' {
        Mock -CommandName Test-RubrikConnection -Verifiable -ModuleName 'Rubrik' -MockWith {}
        Mock -CommandName Test-RubrikSLA -Verifiable -ModuleName 'Rubrik' -MockWith {
            @{ 'slaid' = 'SLA:1111' }
        }
        Mock -CommandName Submit-Request -Verifiable -ModuleName 'Rubrik' -MockWith {
            @{
                'id'                            = 'AG:1111'
                'name'                          = 'AG1'
                'configuredSlaDomainId'         = 'SLA:1111'
                'configuredSlaDomainName'       = 'Gold'
                'logBackupFrequencyinSeconds'   = '60'
                'logRetentionHours'             = '1'
                'copyOnly'                      = 'true'
            }
        }
        It -Name 'Should return Name as value "AG1"' -Test {
            (Set-RubrikAvailabilityGroup -SLA 'Gold' -id 'AG:1111' -CopyOnly).Name |
                Should -BeExactly 'AG1'
        }

        It -Name 'Should return correct LogRetentionHours value' -Test {
            (Set-RubrikAvailabilityGroup -SLA 'Gold' -id 'AG:1111' -LogBackupFrequencyInSeconds 60 -LogRetentionHours 1).logRetentionHours |
                Should -BeExactly '1'
        }
        
        Assert-VerifiableMock
        Assert-MockCalled -CommandName Test-RubrikConnection -ModuleName 'Rubrik' -Exactly 2
        Assert-MockCalled -CommandName Submit-Request -ModuleName 'Rubrik'  -Exactly 2
    }
    Context -Name 'Parameter Validation' {
        It -Name 'Parameter id missing' -Test {
            { Set-RubrikAvailabilityGroup -id  } |
                Should -Throw "Missing an argument for parameter 'id'. Specify a parameter of type 'System.String' and try again."
        }
        It -Name 'Parameter LogBackupFrequencyInSeconds is integer' -Test {
            { Set-RubrikAvailabilityGroup -id 'AG1' -LogBackupFrequencyInSeconds 'sixty'  } |
                Should -Throw "Cannot process argument transformation on parameter 'LogBackupFrequencyInSeconds'."
        }

        It -Name 'Parameter sets should be enforced' -Test {
            { Set-RubrikAvailabilityGroup -SLA 'Gold' -id 'AG:1111' -CopyOnly -LogBackupFrequencyInSeconds 60 -LogRetentionHours 1 } |
                Should -Throw -ErrorId 'AmbiguousParameterSet,Set-RubrikAvailabilityGroup'
        }

        It -Name 'Parameter LogRetentionHours is integer' -Test {
            { Set-RubrikAvailabilityGroup -id 'AG1' -LogRetentionHours 'one'  } |
                Should -Throw "Cannot process argument transformation on parameter 'LogRetentionHours'."
        }
    }
}