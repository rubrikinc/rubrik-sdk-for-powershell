Remove-Module -Name 'Rubrik' -ErrorAction 'SilentlyContinue'
Import-Module -Name './Rubrik/Rubrik.psd1' -Force

foreach ( $privateFunctionFilePath in ( Get-ChildItem -Path './Rubrik/Private' | Where-Object extension -eq '.ps1').FullName  ) {
    . $privateFunctionFilePath
}

Describe -Name 'Public/Get-RubrikVMwareCluster' -Tag 'Public', 'Get-RubrikVMwareCluster' -Fixture {
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
                'name'                   = 'Cluster01'
                'id'                     = 'Cluster:::11111'
                'dataCenterId'           = 'Datacenter:::11111'
                'primaryClusterId'       = '1'
            },
            @{ 
                'name'                   = 'Cluster02'
                'id'                     = 'Cluster:::22222'
                'DatacenterId'           = 'Datacenter:::11111'
                'primaryClusterId'       = '1'
            },
            @{ 
                'name'                   = 'Cluster01'
                'id'                     = 'Cluster:::33333'
                'DatacenterId'           = 'Datacenter:::22222'
                'primaryClusterId'       = '2'
            }
        }
        It -Name 'Should Return count of 2' -Test {
            ( Get-RubrikVMwareCluster -name 'Cluster01').Count |
                Should -BeExactly 2
        }
        It -Name 'Should Return Cluster02' -Test {
            (Get-RubrikVMwareCluster -name 'Cluster02').Name |
                Should -BeExactly 'Cluster02'
        }
        It -Name 'Should Return Datacenter:::11111' -Test {
            ( Get-RubrikVMwareCluster -name 'Cluster02').id |
                Should -BeExactly 'Cluster:::22222'
        }
        It -Name 'Should return count of 4 ' -Test {
            (Get-RubrikVMwareCluster).count |
                Should -BeExactly 3
        }
        Assert-VerifiableMock
        Assert-MockCalled -CommandName Test-RubrikConnection -ModuleName 'Rubrik' -Times 1
        Assert-MockCalled -CommandName Submit-Request -ModuleName 'Rubrik' -Times 1
    }
    Context -Name 'Parameter Validation' {
        It -Name 'ID Missing' -Test {
            { Get-RubrikVMwareCluster -id } |
                Should -Throw "Missing an argument for parameter 'id'. Specify a parameter of type 'System.String' and try again."
        }       
        It -Name 'Name missing' -Test {
            { Get-RubrikVMwareCluster -Name } |
                Should -Throw "Missing an argument for parameter 'Name'. Specify a parameter of type 'System.String' and try again."
        }
    }
}