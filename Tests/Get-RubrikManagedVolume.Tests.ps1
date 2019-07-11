Remove-Module -Name 'Rubrik' -ErrorAction 'SilentlyContinue'
Import-Module -Name './Rubrik/Rubrik.psd1' -Force

foreach ( $privateFunctionFilePath in ( Get-ChildItem -Path './Rubrik/Private' | Where-Object extension -eq '.ps1').FullName  ) {
    . $privateFunctionFilePath
}

Describe -Name 'Public/Get-RubrikManagedVolume' -Tag 'Public', 'Get-RubrikManagedVolume' -Fixture {
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
                'id'                        = 'ManagedVolume:::11111'
                'name'                      = 'OracleMV1'
                'state'                     = 'Exported'
                'primaryClusterId'          = 'cluster01'
                'configuredSlaDomainName'   = 'Gold'
                'isRelic'                   = 'False'
                'effectiveSlaDomainId'      = 'test-sla_id'
            },
            @{ 
                'id'                        = 'ManagedVolume:::22222'
                'name'                      = 'SQLMV'
                'state'                     = 'Exported'
                'primaryClusterId'          = 'cluster01'
                'configuredSlaDomainName'   = 'Gold'
                'isRelic'                   = 'False'
                'effectiveSlaDomainId'      = 'test-sla_id'
            },
            @{ 
                'id'                        = 'ManagedVolume:::33333'
                'name'                      = 'Postgres'
                'state'                     = 'Exported'
                'primaryClusterId'          = 'cluster02'
                'configuredSlaDomainName'   = 'Silver'
                'isRelic'                   = 'True'
                'effectiveSlaDomainId'      = 'test-sla_id2'
            },
            @{ 
                'id'                        = 'ManagedVolume:::44444'
                'name'                      = 'OracleMV2'
                'state'                     = 'Exported'
                'primaryClusterId'          = 'cluster01'
                'configuredSlaDomainName'   = 'Silver'
                'isRelic'                   = 'False'
                'effectiveSlaDomainId'      = 'test-sla_id2'
            },
            @{ 
                'id'                        = 'ManagedVolume:::55555'
                'name'                      = 'OracleMV3'
                'state'                     = 'Exported'
                'primaryClusterId'          = 'cluster01'
                'configuredSlaDomainName'   = 'Gold'
                'isRelic'                   = 'True'
                'effectiveSlaDomainId'      = 'test-sla_id'
            }
        }
        It -Name 'Should Return count of 5' -Test {
            (Get-RubrikManagedVolume).Count |
                Should -BeExactly 5
        }
        It -Name 'Name filter non existant should return count of 0' -Test {
            (Get-RubrikManagedVolume -Name 'nonexistant').Count |
                Should -BeExactly 0
        }  
        #!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! left off here
        It -Name 'Name filter non existant should return count of 0' -Test {
            (Get-RubrikManagedVolume -ID 'ManagedVolume:::55555').Count |
                Should -BeExactly 0
        }  
        Assert-VerifiableMock
        Assert-MockCalled -CommandName Test-RubrikConnection -ModuleName 'Rubrik' -Times 1
        Assert-MockCalled -CommandName Submit-Request -ModuleName 'Rubrik' -Times 1
    }

}