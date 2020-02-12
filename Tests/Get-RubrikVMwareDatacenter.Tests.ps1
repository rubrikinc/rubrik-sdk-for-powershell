Remove-Module -Name 'Rubrik' -ErrorAction 'SilentlyContinue'
Import-Module -Name './Rubrik/Rubrik.psd1' -Force

foreach ( $privateFunctionFilePath in ( Get-ChildItem -Path './Rubrik/Private' | Where-Object extension -eq '.ps1').FullName  ) {
    . $privateFunctionFilePath
}

Describe -Name 'Public/Get-RubrikVMwareDatacenter' -Tag 'Public', 'Get-RubrikVMwareDatacenter' -Fixture {
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
        Mock -CommandName Submit-Request -Verifiable -ModuleName 'Rubrik' -MockWith {
            @{
                'hasmore'   = 'false'
                'total'     = '1'
                'data'      =
                @{ 
                    'name'                   = 'datacenter01'
                    'id'                     = 'Datacenter:::11111'
                    'vCenterId'              = 'vCenter:::11111'
                    'primaryClusterId'       = '1'
                },
                @{ 
                    'name'                   = 'datacenter02'
                    'id'                     = 'Datacenter:::22222'
                    'vCenterId'              = 'vCenter:::11111'
                    'primaryClusterId'       = '1'
                },
                @{ 
                    'name'                   = 'datacenter01'
                    'id'                     = 'Datacenter:::33333'
                    'vCenterId'              = 'vCenter:::22222'
                    'primaryClusterId'       = '2'
                }
            }
        }
        It -Name 'Should Return count of 2' -Test {
            ( Get-RubrikVMwareDatacenter -name 'datacenter01').Count |
                Should -BeExactly 2
        }
        It -Name 'Should Return datacenter02' -Test {
            (Get-RubrikVMwareDatacenter -name 'datacenter02').Name |
                Should -BeExactly 'datacenter02'
        }
        It -Name 'Should Return vCenter:::11111' -Test {
            ( Get-RubrikVMwareDatacenter -name 'datacenter02').id |
                Should -BeExactly 'Datacenter:::22222'
        }
        It -Name 'Should return count of 4 ' -Test {
            (Get-RubrikVMwareDatacenter).count |
                Should -BeExactly 3
        }
        Assert-VerifiableMock
        Assert-MockCalled -CommandName Test-RubrikConnection -ModuleName 'Rubrik' -Times 1
        Assert-MockCalled -CommandName Submit-Request -ModuleName 'Rubrik' -Times 1
    }
    Context -Name 'Parameter Validation' {
        It -Name 'ID Missing' -Test {
            { Get-RubrikVMwareDatacenter -id } |
                Should -Throw "Missing an argument for parameter 'id'. Specify a parameter of type 'System.String' and try again."
        }       
        It -Name 'Name missing' -Test {
            { Get-RubrikVMwareDatacenter -Name } |
                Should -Throw "Missing an argument for parameter 'Name'. Specify a parameter of type 'System.String' and try again."
        }
    }
}