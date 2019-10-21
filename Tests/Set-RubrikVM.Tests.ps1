Remove-Module -Name 'Rubrik' -ErrorAction 'SilentlyContinue'
Import-Module -Name './Rubrik/Rubrik.psd1' -Force

foreach ( $privateFunctionFilePath in ( Get-ChildItem -Path './Rubrik/Private' | Where-Object extension -eq '.ps1').FullName  ) {
    . $privateFunctionFilePath
}

Describe -Name 'Public/Set-RubrikVM' -Tag 'Public', 'Set-RubrikVM' -Fixture {
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
    
    
    Context -Name 'Parameter/PauseBackups' {
        Mock -CommandName Test-RubrikConnection -Verifiable -ModuleName 'Rubrik' -MockWith {}
        Mock -CommandName Submit-Request -Verifiable -ModuleName 'Rubrik' -MockWith {
            @{ 
                'id'                     = 'VirtualMachine:::aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee-vm-12345'
                'isVmPaused'             = $true
            }
        }
        
        It -Name 'Should set PauseBackups' -Test {
            ( Set-RubrikVM -id 'VirtualMachine:::aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee-vm-12345' -PauseBackups ).isVmPaused |
                Should -BeExactly $true
        }
        
        It -Name 'Verify switch param - PauseBackups:$true - Switch Param' -Test {
            $Output = & {
                Set-RubrikVM -id 'VirtualMachine:::aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee-vm-12345' -PauseBackups -Verbose 4>&1
            }
            (-join $Output) | Should -BeLike '*isVmPaused*true*'
        }
        
        It -Name 'Verify switch param - PauseBackups:$false - Switch Param' -Test {
            $Output = & {
                Set-RubrikVM -id 'VirtualMachine:::aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee-vm-12345' -PauseBackups:$false -Verbose 4>&1
            }
            (-join $Output) | Should -BeLike '*isVmPaused*false*'
        }
        
        It -Name 'Verify switch param - No PauseBackups - Switch Param' -Test {
            $Output = & {
                Set-RubrikVM -id 'VirtualMachine:::aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee-vm-12345' -Verbose 4>&1
            }
            (-join $Output) | Should -Not -BeLike '*isVmPaused*'
        }
        
        Assert-VerifiableMock
        Assert-MockCalled -CommandName Test-RubrikConnection -ModuleName 'Rubrik' -Exactly 4
        Assert-MockCalled -CommandName Submit-Request -ModuleName 'Rubrik' -Exactly 4
    }

    Context -Name 'Parameter/SnapConsistency' {
        Mock -CommandName Test-RubrikConnection -Verifiable -ModuleName 'Rubrik' -MockWith {}
        Mock -CommandName Submit-Request -Verifiable -ModuleName 'Rubrik' -MockWith {
            @{ 
                'id'                            = 'VirtualMachine:::aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee-vm-12345'
                'snapshotConsistencyMandate'    = 'CRASH_CONSISTENT'
            }
        }
        It -Name 'Should set SnapConsistency' -Test {
            ( Set-RubrikVM -id 'VirtualMachine:::aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee-vm-12345' -SnapConsistency 'CRASH_CONSISTENT').snapshotConsistencyMandate |
                Should -BeExactly 'CRASH_CONSISTENT'
        }
        Assert-VerifiableMock
        Assert-MockCalled -CommandName Test-RubrikConnection -ModuleName 'Rubrik' -Exactly 1
        Assert-MockCalled -CommandName Submit-Request -ModuleName 'Rubrik' -Exactly 1
    }
    
    Context -Name 'Parameter Validation' {
        It -Name 'Parameter ID cannot be $null' -Test {
            { Set-RubrikVM -Id $null } |
                Should -Throw "Cannot validate argument on parameter 'ID'"
        }
        It -Name 'Parameter ID cannot be empty' -Test {
            { Set-RubrikVM -Id '' } |
                Should -Throw "Cannot validate argument on parameter 'ID'"
        }
        It -Name 'Parameter SnapConsistency must have a valid value' -Test {
            { Set-RubrikVM -Id VirtualMachine:::1226ff04-6100-454f-905b-5df817b6981a-vm-1025 -SnapConsistency foo} |
                Should -Throw "Cannot validate argument on parameter 'SnapConsistency'."
        }
        It -Name 'Parameter MaxNestedSnapshots must have a valid value' -Test {
            { Set-RubrikVM -Id VirtualMachine:::1226ff04-6100-454f-905b-5df817b6981a-vm-1025 -MaxNestedSnapshots 5} |
                Should -Throw "Cannot validate argument on parameter 'MaxNestedSnapshots'."
        }
    }
}