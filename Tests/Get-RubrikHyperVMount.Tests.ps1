Remove-Module -Name 'Rubrik' -ErrorAction 'SilentlyContinue'
Import-Module -Name './Rubrik/Rubrik.psd1' -Force

foreach ( $privateFunctionFilePath in ( Get-ChildItem -Path './Rubrik/Private' | Where-Object extension -eq '.ps1').FullName  ) {
    . $privateFunctionFilePath
}

Describe -Name 'Public/Get-RubrikHyperVMount' -Tag 'Public', 'Get-RubrikHyperVMount' -Fixture {
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
                'id'                    = '11-22-33'
                'vmId'                  = 'HypervVirtualMachine:::111'
                'isReady'               = 'True'
                'hostId'                = 'HypervServer:::111'
            },
            @{ 
                'id'                    = '11-22-44'
                'vmId'                  = 'HypervVirtualMachine:::111'
                'isReady'               = 'True'
                'hostId'                = 'HypervServer:::222'
            },
            @{ 
                'id'                    = '11-22-55'
                'vmId'                  = 'HypervVirtualMachine:::222'
                'isReady'               = 'True'
                'hostId'                = 'HypervServer:::111'
            },
            @{ 
                'id'                    = '11-22-66'
                'vmId'                  = 'HypervVirtualMachine:::333'
                'isReady'               = 'True'
                'hostId'                = 'HypervServer:::111'
            }
        }
        It -Name 'Filter should return count of 4' -Test {
            ( Get-RubrikHyperVMount).Count |
                Should -BeExactly 4
        }
        It -Name 'Should return proper host' -Test {
            (Get-RubrikHyperVMount -id '11-22-44').hostId |
                Should -BeExactly 'HypervServer:::222'
        }
        It -Name 'Filter vmId should return count of 2' -Test {
            ( Get-RubrikHyperVMount -VMID 'HypervVirtualMachine:::111').Count |
                Should -BeExactly 2
        }
        It -Name 'Nonexistant id should return count of 0 ' -Test {
            (Get-RubrikHyperVMount -id 'nonexistant').count |
                Should -BeExactly 0
        }
        Assert-VerifiableMock
        Assert-MockCalled -CommandName Test-RubrikConnection -ModuleName 'Rubrik' -Exactly 4
        Assert-MockCalled -CommandName Submit-Request -ModuleName 'Rubrik' -Exactly 4
    }
}