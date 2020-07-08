Remove-Module -Name 'Rubrik' -ErrorAction 'SilentlyContinue'
Import-Module -Name './Rubrik/Rubrik.psd1' -Force

foreach ( $privateFunctionFilePath in ( Get-ChildItem -Path './Rubrik/Private' | Where-Object extension -eq '.ps1').FullName  ) {
    . $privateFunctionFilePath
}

Describe -Name 'Public/New-RubrikReport' -Tag 'Public', 'New-RubrikReport' -Fixture {
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

    Context -Name 'Returned Results' {
        Mock -CommandName Test-RubrikConnection -Verifiable -ModuleName 'Rubrik' -MockWith {}    
        Mock -CommandName Submit-Request -Verifiable -ModuleName 'Rubrik' -MockWith {
            @{ 
                'id'                    = 'CustomReport:11111'
                'name'                  = 'TestReport'
                'reportTemplate'        = 'SystemCapacity'
                'reportType'            = 'Custom'
            }
        }
        It -Name 'Returns newly created report' -Test {
            ( New-RubrikReport -Name 'TestReport' -ReportTemplate 'SystemCapacity').reportTemplate |
                Should -BeExactly 'SystemCapacity'
        } 
        Assert-VerifiableMock
        Assert-MockCalled -CommandName Test-RubrikConnection -ModuleName 'Rubrik' -Times 1
        Assert-MockCalled -CommandName Submit-Request -ModuleName 'Rubrik' -Times 1
    }
    Context -Name 'Parameter Validation' {
        It -Name 'Name cannot be null or empty' -Test {
            { New-RubrikReport -name $null -ReportTemplate 'SystemCapacity' } |
                Should -Throw "Cannot bind argument to parameter 'Name' because it is an empty string."
        }
        It -Name 'ReportTemplate must be present' -Test {
            { New-RubrikReport -name 'TEST' -ReportTemplate   } |
                Should -Throw "Missing an argument for parameter 'ReportTemplate'"
        }
        It -Name 'ValidateSet ReportTemplate' -Test {
            { New-RubrikReport -name 'Test' -ReportTemplate 'NotCorrect'  } |
                Should -Throw 'The argument "NotCorrect" does not belong to the set "CapacityOverTime,ObjectProtectionSummary,ObjectTaskSummary,ObjectIndexingSummary,ProtectionTasksDetails,ProtectionTasksSummary,RecoveryTasksDetails,SlaComplianceSummary,SystemCapacity" specified by the ValidateSet attribute. Supply an argument that is in the set and then try the command again.'
        }
    }
}