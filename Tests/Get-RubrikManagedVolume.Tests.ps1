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
        Mock -CommandName Test-RubrikSLA -Verifiable -ModuleName 'Rubrik' -MockWith {
            @{ 'slaid' = '12345678-1234-abcd-8910-1234567890ab' }
        }
        Mock -CommandName Submit-Request -Verifiable -ModuleName 'Rubrik' -MockWith {
            @{
                'id'                        = 'ManagedVolume:::11111'
                'isDeleted'                 = 'False'
                'primaryClusterId'          = 'local'
                'name'                      = 'OracleMV'
                'isRelic'                   = 'False'
                'effectiveSlaDomainId'      = '12345678-1234-abcd-8910-1234567890cab'
                'configuredSlaDomainId'     = '12345678-1234-abcd-8910-1234567890cab'
                'effectiveSlaDomainName'    = 'Gold'
                'configuredSlaDomainName'   = 'Gold'
            },
            @{
                'id'                        = 'ManagedVolume:::22222'
                'isDeleted'                 = 'False'
                'primaryClusterId'          = 'local'
                'name'                      = 'SQLMV'
                'isRelic'                   = 'False'
                'effectiveSlaDomainId'      = '12345678-1234-abcd-8910-1234567890abc'
                'configuredSlaDomainId'     = '12345678-1234-abcd-8910-1234567890abc'
                'effectiveSlaDomainName'    = 'Bronze'
                'configuredSlaDomainName'   = 'Bronze'
            },
            @{
                'id'                        = 'ManagedVolume:::33333'
                'isDeleted'                 = 'False'
                'primaryClusterId'          = 'local'
                'name'                      = 'LinMV'
                'isRelic'                   = 'False'
                'effectiveSlaDomainId'      = '12345678-1234-abcd-8910-1234567890bac'
                'configuredSlaDomainId'     = '12345678-1234-abcd-8910-1234567890bac'
                'effectiveSlaDomainName'    = 'Silver'
                'configuredSlaDomainName'   = 'Silver'
            }
        }
        
        It -Name 'Should Return count of 2' -Test {
            (Get-RubrikManagedVolume).Count |
                Should -BeExactly 2
        }
        It -Name 'Name filter non existant should return count of 0' -Test {
            (Get-RubrikManagedVolume -Name 'nonexistant').Count |
                Should -BeExactly 0
        } 
        It -Name 'Name Filter - ID should be ManagedVolume:::22222' -Test {
            (Get-RubrikManagedVolume -name 'SQLMV').id |
                Should -BeExactly 'ManagedVolume:::22222'
        } 
        It -Name 'SLA Filter should be count of 1' -Test {
            (Get-RubrikManagedVolume -SLA "Bronze" | Measure-Object).Count |
                Should -BeExactly 1
        } 
        It -Name 'SLA ID Filter should be count of 1' -Test {
            (Get-RubrikManagedVolume -SLAID "12345678-1234-abcd-8910-1234567890abc" | Measure-Object).Count |
                Should -BeExactly 1
        } 
        It -Name 'Missing ID Exception' -Test {
            { Get-RubrikManagedVolume -id  } |
                Should -Throw "Missing an argument for parameter 'id'. Specify a parameter of type 'System.String' and try again."
        } 
        It -Name 'Null or empty ID Exception' -Test {
            { Get-RubrikManagedVolume -id '' } |
                Should -Throw "Cannot validate argument on parameter 'id'. The argument is null or empty. Provide an argument that is not null or empty, and then try the command again."
        } 

        Assert-VerifiableMock
        Assert-MockCalled -CommandName Test-RubrikConnection -ModuleName 'Rubrik' -Times 1
        Assert-MockCalled -CommandName Submit-Request -ModuleName 'Rubrik' -Times 1
    }

}