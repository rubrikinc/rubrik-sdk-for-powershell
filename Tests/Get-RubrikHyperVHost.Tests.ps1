Remove-Module -Name 'Rubrik' -ErrorAction 'SilentlyContinue'
Import-Module -Name './Rubrik/Rubrik.psd1' -Force

foreach ( $privateFunctionFilePath in ( Get-ChildItem -Path './Rubrik/Private' | Where-Object extension -eq '.ps1').FullName  ) {
    . $privateFunctionFilePath
}

Describe -Name 'Public/Get-RubrikHyperVHost' -Tag 'Public', 'Get-RubrikHyperVHost' -Fixture {
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
                'total'     = '1'
                'hasMore'   = 'false'
                'data' =  
                @{ 
                    'name'                   = 'hyperv52'
                    'id'                     = 'HypervServer:::11111'
                    'primaryClusterId'       = '1'
                },
                @{ 
                    'name'                   = 'hyperv51'
                    'id'                     = 'HypervServer:::22222'
                    'primaryClusterId'       = '1'
                },
                @{ 
                    'name'                   = 'hyperv53'
                    'id'                     = 'HypervServer:::33333'
                    'primaryClusterId'       = '2'
                }
            }
        }
        It -Name 'Should Return hyperv52' -Test {
            (Get-RubrikHyperVHost -name 'hyperv52').Name |
                Should -BeExactly 'hyperv52'
        }
        It -Name 'Should Return HypervServer:::33333' -Test {
            ( Get-RubrikHyperVHost -name 'hyperv53').id |
                Should -BeExactly 'HypervServer:::33333'
        }
        It -Name 'Should return count of 3 ' -Test {
            (Get-RubrikHyperVHost).count |
                Should -BeExactly 3
        }
        Assert-VerifiableMock
        Assert-MockCalled -CommandName Test-RubrikConnection -ModuleName 'Rubrik' -Times 1
        Assert-MockCalled -CommandName Submit-Request -ModuleName 'Rubrik' -Times 1
    }
}