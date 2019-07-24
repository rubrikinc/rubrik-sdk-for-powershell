Remove-Module -Name 'Rubrik' -ErrorAction 'SilentlyContinue'
Import-Module -Name './Rubrik/Rubrik.psd1' -Force

foreach ( $privateFunctionFilePath in ( Get-ChildItem -Path './Rubrik/Private' | Where-Object extension -eq '.ps1').FullName  ) {
    . $privateFunctionFilePath
}

Describe -Name 'Public/Get-RubrikReport' -Tag 'Public', 'Get-RubrikReport' -Fixture {
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

    Context -Name 'Returning Results' {
        Mock -CommandName Test-RubrikConnection -Verifiable -ModuleName 'Rubrik' -MockWith {}
        Mock -CommandName Submit-Request -Verifiable -ModuleName 'Rubrik' -MockWith {
            @{ 
                'name'                   = 'TestReport1'
                'updateStatus'           = 'Ready'
                'reportType'             = 'Custom'
                'id'                     = 'CustomReport:::11111'
            },
            @{ 
                'name'                   = 'TestReport2'
                'updateStatus'           = 'Ready'
                'reportType'             = 'Canned'
                'id'                     = 'CustomReport:::22222'
            }
        }
        It -Name 'Results returning' -Test {
            ( Get-RubrikReport).Count |
                Should -BeExactly 2
        } 
        Assert-VerifiableMock
        Assert-MockCalled -CommandName Test-RubrikConnection -ModuleName 'Rubrik' -Times 1
        Assert-MockCalled -CommandName Submit-Request -ModuleName 'Rubrik' -Times 1
    }
    Context -Name 'Parameter Validation' {
        It -Name 'ID Missing' -Test {
            { Get-RubrikReport -id } |
                Should -Throw "Missing an argument for parameter 'id'. Specify a parameter of type 'System.String' and try again."
        }       
        It -Name 'Name must be System.String' -Test {
            { Get-RubrikReport -Name } |
                Should -Throw "Missing an argument for parameter 'Name'. Specify a parameter of type 'System.String' and try again."
        }
        It -Name 'Type validation must be canned or custom' -Test {
            { Get-RubrikReport -Type 'NewReport' } |
                Should -Throw 'The argument "NewReport" does not belong to the set "Canned,Custom" specified by the ValidateSet attribute. Supply an argument that is in the set and then try the command again.'
        }
    }
}