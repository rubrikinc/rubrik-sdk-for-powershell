Remove-Module -Name 'Rubrik' -ErrorAction 'SilentlyContinue'
Import-Module -Name './Rubrik/Rubrik.psd1' -Force

foreach ( $privateFunctionFilePath in ( Get-ChildItem -Path './Rubrik/Private' | Where-Object extension -eq '.ps1').FullName  ) {
    . $privateFunctionFilePath
}

Describe -Name 'Public/Get-RubrikNetworkThrottle' -Tag 'Public', 'Get-RubrikNetworkThrottle' -Fixture {
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
                'hasmore'   = 'false'
                'total'     = '2'
                'data'      =
                @{ 
                    'resourceId'           = 'ArchivalEgress'
                    'isEnabled'            = 'True'
                    'defaultThrottleLimit' = '9223372036854'
                    'scheduledThrottles'   = ''
                },
                @{ 
                    'resourceId'           = 'ReplicationEgress'
                    'isEnabled'            = 'False'
                    'defaultThrottleLimit' = '9223372036854'
                    'scheduledThrottles'   = ''
                }
            }
        }
        It -Name 'No parameters returns all results' -Test {
            @( Get-RubrikNetworkThrottle).Count |
                Should -BeExactly 2
        }

        Assert-VerifiableMock
        Assert-MockCalled -CommandName Test-RubrikConnection -ModuleName 'Rubrik' -Exactly 1
        Assert-MockCalled -CommandName Submit-Request -ModuleName 'Rubrik' -Exactly 1
    }
    Context -Name 'Parameter Validation' {
        It -Name 'ThrottleType ValidateSet' -Test {
            { Get-RubrikNetworkThrottle -ThrottleType "no such throttle type" } |
                Should -Throw "Cannot validate argument on parameter 'ThrottleType'. The argument `"no such throttle type`" does not belong to the set `"ArchivalEgress,ReplicationEgress`" specified by the ValidateSet attribute."
        }       
    }

}