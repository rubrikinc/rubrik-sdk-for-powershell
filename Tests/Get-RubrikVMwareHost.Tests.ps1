Remove-Module -Name 'Rubrik' -ErrorAction 'SilentlyContinue'
Import-Module -Name './Rubrik/Rubrik.psd1' -Force

foreach ( $privateFunctionFilePath in ( Get-ChildItem -Path './Rubrik/Private' | Where-Object extension -eq '.ps1').FullName  ) {
    . $privateFunctionFilePath
}

Describe -Name 'Public/Get-RubrikVMwareHost' -Tag 'Public', 'Get-RubrikVMwareHost' -Fixture {
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
                'hasMore' = 'false'
                'total' = '4'
                'data' =
                @{ 
                    'name'                   = 'esxi01.domain.local'
                    'id'                     = 'VMwareHost:::11111'
                    'datacenterId'           = 'Datacenter:::11111'
                    'primaryClusterId'       = '1'
                },
                @{ 
                    'name'                   = 'esxi02.domain.local'
                    'id'                     = 'VMwareHost:::22222'
                    'datacenterId'           = 'Datacenter:::11111'
                    'primaryClusterId'       = '1'
                },
                @{ 
                    'name'                   = 'esxi02.domain.local'
                    'id'                     = 'VMwareHost:::33333'
                    'datacenterId'           = 'Datacenter:::22222'
                    'primaryClusterId'       = '2'
                },
                @{ 
                    'name'                   = 'esxi04.domain.local'
                    'id'                     = 'VMwareHost:::44444'
                    'datacenterId'           = 'Datacenter:::22222'
                    'primaryClusterId'       = '2'
                }
            }
        }
        It -Name 'Should Return count of 2' -Test {
            ( Get-RubrikVMWareHost -name 'esxi02.domain.local').Count |
                Should -BeExactly 2
        }
        It -Name 'Should Return esxi01.domain.local' -Test {
            (Get-RubrikVMWareHost -name 'esxi01.domain.local').Name |
                Should -BeExactly 'esxi01.domain.local'
        }
        It -Name 'Should Return VMwareHost:::44444' -Test {
            ( Get-RubrikVMWareHost -name 'esxi04.domain.local').id |
                Should -BeExactly 'VMwareHost:::44444'
        }
        It -Name 'Should return count of 4 ' -Test {
            (Get-RubrikVMwareHost).count |
                Should -BeExactly 4
        }
        Assert-VerifiableMock
        Assert-MockCalled -CommandName Test-RubrikConnection -ModuleName 'Rubrik' -Times 1
        Assert-MockCalled -CommandName Submit-Request -ModuleName 'Rubrik' -Times 1
    }
}