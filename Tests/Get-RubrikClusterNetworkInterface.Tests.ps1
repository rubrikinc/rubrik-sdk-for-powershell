Remove-Module -Name 'Rubrik' -ErrorAction 'SilentlyContinue'
Import-Module -Name './Rubrik/Rubrik.psd1' -Force

foreach ( $privateFunctionFilePath in ( Get-ChildItem -Path './Rubrik/Private' | Where-Object extension -eq '.ps1').FullName  ) {
    . $privateFunctionFilePath
}

Describe -Name 'Public/Get-RubrikClusterNetworkInterface' -Tag 'Public', 'Get-RubrikClusterNetworkInterface' -Fixture {
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
        Mock -CommandName Test-RubrikConnection -Verifiable -ModuleName 'Rubrik' -MockWith { }
        Mock -CommandName Submit-Request -Verifiable -ModuleName 'Rubrik' -MockWith {
            @{ 
                'node'          = 'RVM11111'
                'interfaceType' = 'Management'
                'ipAddress'     = '10.10.10.101'
                'interfaceName' = 'bond0'
                'netmask'       = '255.255.255.0'   
            },
            @{ 
                'node'          = 'RVM22222'
                'interfaceType' = 'Management'
                'ipAddress'     = '10.10.10.102'
                'interfaceName' = 'bond0'
                'netmask'       = '255.255.255.0'   
            },
            @{ 
                'node'          = 'RVM33333'
                'interfaceType' = 'Management'
                'ipAddress'     = '10.10.10.103'
                'interfaceName' = 'bond0'
                'netmask'       = '255.255.255.0'   
            },
            @{ 
                'node'          = 'RVM44444'
                'interfaceType' = 'Management'
                'ipAddress'     = '10.10.10.104'
                'interfaceName' = 'bond0'
                'netmask'       = '255.255.255.0'   
            }

        }
        It -Name 'No parameters returns all results' -Test {
            @( Get-RubrikClusterNetworkInterface).Count |
                Should -BeExactly 4
        }
        It -Name 'IP should be 10.10.10.104' -Test {
            @( Get-RubrikClusterNetworkInterface -node "RVM44444").ipAddress |
                Should -BeExactly '10.10.10.104'
        }
        It -Name 'Count should be 4' -Test {
            @( Get-RubrikClusterNetworkInterface -interface "bond0").Count |
                Should -BeExactly 4
        }

        Assert-VerifiableMock
        Assert-MockCalled -CommandName Test-RubrikConnection -ModuleName 'Rubrik' -Exactly 3
        Assert-MockCalled -CommandName Submit-Request -ModuleName 'Rubrik' -Exactly 3
    }
}