Remove-Module -Name 'Rubrik' -ErrorAction 'SilentlyContinue'
Import-Module -Name './Rubrik/Rubrik.psd1' -Force

foreach ( $privateFunctionFilePath in ( Get-ChildItem -Path './Rubrik/Private' | Where-Object extension -eq '.ps1').FullName  ) {
    . $privateFunctionFilePath
}

Describe -Name 'Public/Set-RubrikNutanixVM' -Tag 'Public', 'Set-RubrikNutanixVM' -Fixture {
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
                'id'                     = 'NutanixVirtualMachine:::aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee-vm-ffffffff-0000-1111-2222-333333333333'
                'isPaused'             = $true
            }
        }
        It -Name 'Should set PauseBackups' -Test {
            ( Set-RubrikNutanixVM -id 'NutanixVirtualMachine:::aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee-vm-ffffffff-0000-1111-2222-333333333333' -PauseBackups).isPaused |
                Should -BeExactly $true
        }
        
        It -Name 'Verify switch param - PauseBackups:$true - Switch Param' -Test {
            $Output = & {
                Set-RubrikNutanixVM -id 'NutanixVirtualMachine:::aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee-vm-ffffffff-0000-1111-2222-333333333333' -PauseBackups -Verbose 4>&1
            }
            (-join $Output) | Should -BeLike '*isPaused*true*'
        }
        
        It -Name 'Verify switch param - PauseBackups:$false - Switch Param' -Test {
            $Output = & {
                Set-RubrikNutanixVM -id 'NutanixVirtualMachine:::aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee-vm-ffffffff-0000-1111-2222-333333333333' -PauseBackups:$false -Verbose 4>&1
            }
            (-join $Output) | Should -BeLike '*isPaused*false*'
        }
        
        It -Name 'Verify switch param - No PauseBackups - Switch Param' -Test {
            $Output = & {
                Set-RubrikNutanixVM -id 'NutanixVirtualMachine:::aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee-vm-ffffffff-0000-1111-2222-333333333333' -Verbose 4>&1
            }
            (-join $Output) | Should -Not -BeLike '*isPaused*'
        }
        
        Assert-VerifiableMock
        Assert-MockCalled -CommandName Test-RubrikConnection -ModuleName 'Rubrik' -Exactly 4
        Assert-MockCalled -CommandName Submit-Request -ModuleName 'Rubrik' -Exactly 4
    }

    Context -Name 'Parameter/SnapConsistency' {
        Mock -CommandName Test-RubrikConnection -Verifiable -ModuleName 'Rubrik' -MockWith {}
        Mock -CommandName Submit-Request -Verifiable -ModuleName 'Rubrik' -MockWith {
            @{ 
                'id'                            = 'NutanixVirtualMachine:::aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee-vm-ffffffff-0000-1111-2222-333333333333'
                'snapshotConsistencyMandate'    = 'CRASH_CONSISTENT'
            }
        }
        It -Name 'Should set SnapConsistency' -Test {
            ( Set-RubrikNutanixVM -id 'NutanixVirtualMachine:::aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee-vm-ffffffff-0000-1111-2222-333333333333' -SnapConsistency 'CRASH_CONSISTENT').snapshotConsistencyMandate |
                Should -BeExactly 'CRASH_CONSISTENT'
        }
        Assert-VerifiableMock
        Assert-MockCalled -CommandName Test-RubrikConnection -ModuleName 'Rubrik' -Exactly 1
        Assert-MockCalled -CommandName Submit-Request -ModuleName 'Rubrik' -Exactly 1
    }
    
    Context -Name 'Parameter Validation' {
        It -Name 'Parameter ID cannot be $null' -Test {
            { Set-RubrikNutanixVM -Id $null } |
                Should -Throw "Cannot validate argument on parameter 'ID'"
        }
        It -Name 'Parameter ID cannot be empty' -Test {
            { Set-RubrikNutanixVM -Id '' } |
                Should -Throw "Cannot validate argument on parameter 'ID'"
        }
        It -Name 'Parameter SnapConsistency must have a valid value' -Test {
            { Set-RubrikNutanixVM -Id NutanixVirtualMachine:::aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee-vm-ffffffff-0000-1111-2222-333333333333 -SnapConsistency foo} |
                Should -Throw "Cannot validate argument on parameter 'SnapConsistency'."
        }
    }
}