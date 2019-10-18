Remove-Module -Name 'Rubrik' -ErrorAction 'SilentlyContinue'
Import-Module -Name './Rubrik/Rubrik.psd1' -Force

foreach ( $privateFunctionFilePath in ( Get-ChildItem -Path './Rubrik/Private' | Where-Object extension -eq '.ps1').FullName  ) {
    . $privateFunctionFilePath
}

Describe -Name 'Public/Set-RubrikMount' -Tag 'Public', 'Set-RubrikMount' -Fixture {
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
                'vmId'                  = 'VirtualMachine:::111'
                'isReady'               = 'True'
                'hostId'                = 'Host:::111'
                'powerStatus'           = 'poweredOff'
            }
        }
        It -Name 'Should return poweredOff status' -Test {
            (Set-RubrikMount -id '11-22-33' -PowerOn:$false).powerStatus |
                Should -BeExactly 'poweredOff'
        }
        It -Name 'Parameter ID cannot be $null' -Test {
            { Set-RubrikMount -Id $null } |
                Should -Throw "Cannot bind argument to parameter 'id' because it is an empty string."
        }
        It -Name 'Parameter ID cannot be empty' -Test {
            { Set-RubrikMount -Id '' } |
                Should -Throw "Cannot bind argument to parameter 'id' because it is an empty string."
        } 
        Assert-VerifiableMock
        Assert-MockCalled -CommandName Test-RubrikConnection -ModuleName 'Rubrik' -Exactly 1
        Assert-MockCalled -CommandName Submit-Request -ModuleName 'Rubrik' -Exactly 1
    }
}