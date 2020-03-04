Remove-Module -Name 'Rubrik' -ErrorAction 'SilentlyContinue'
Import-Module -Name './Rubrik/Rubrik.psd1' -Force

foreach ( $privateFunctionFilePath in ( Get-ChildItem -Path './Rubrik/Private' | Where-Object extension -eq '.ps1').FullName  ) {
    . $privateFunctionFilePath
}

Describe -Name 'Public/New-RubrikHyperVVMMount' -Tag 'Public', 'New-RubrikHyperVVMMount' -Fixture {
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

    Context -Name 'Parameter Validation' {
        Mock -CommandName Test-RubrikConnection -Verifiable -ModuleName 'Rubrik' -MockWith {}
        Mock -CommandName Submit-Request -Verifiable -ModuleName 'Rubrik' -MockWith {
            @{
                'id'       = 'MOUNT_HYPERV_SNAPSHOT_11111'
                'status'   = 'QUEUED'
                'progress' = '0'
            }
        }

        It -Name 'Should create mount with QUEUED status' -Test {
            ( New-RubrikHyperVVMMount -Id 'snapshotid').status |
                Should -BeExactly 'QUEUED'
        }
        
        It -Name 'Verify switch param - DisableNetwork:$true - Switch Param' -Test {
            $Output = & {
                New-RubrikHyperVVMMount -Id 'snapshotid' -DisableNetwork -Verbose 4>&1
            }
            (-join $Output) | Should -BeLike '*disableNetwork*true*'
        }
        
        It -Name 'Verify switch param - DisableNetwork:$false - Switch Param' -Test {
            $Output = & {
                New-RubrikHyperVVMMount -Id 'snapshotid' -DisableNetwork:$false -Verbose 4>&1
            }
            (-join $Output) | Should -BeLike '*disableNetwork*false*'
        }
        
        It -Name 'Verify switch param - No DisableNetwork - Switch Param' -Test {
            $Output = & {
                New-RubrikHyperVVMMount -Id 'snapshotid' -Verbose 4>&1
            }
            (-join $Output) | Should -Not -BeLike '*disableNetwork*'
        }
        
        It -Name 'Verify switch param - RemoveNetworkDevices:$true - Switch Param' -Test {
            $Output = & {
                New-RubrikHyperVVMMount -Id 'snapshotid' -RemoveNetworkDevices -Verbose 4>&1
            }
            (-join $Output) | Should -BeLike '*RemoveNetworkDevices*true*'
        }
        
        It -Name 'Verify switch param - RemoveNetworkDevices:$false - Switch Param' -Test {
            $Output = & {
                New-RubrikHyperVVMMount -Id 'snapshotid' -RemoveNetworkDevices:$false -Verbose 4>&1
            }
            (-join $Output) | Should -BeLike '*RemoveNetworkDevices*false*'
        }
        
        It -Name 'Verify switch param - No RemoveNetworkDevices - Switch Param' -Test {
            $Output = & {
                New-RubrikHyperVVMMount -Id 'snapshotid' -Verbose 4>&1
            }
            (-join $Output) | Should -Not -BeLike '*RemoveNetworkDevices*'
        }
        
        It -Name 'Verify switch param - PowerOn:$true - Switch Param' -Test {
            $Output = & {
                New-RubrikHyperVVMMount -Id 'snapshotid' -PowerOn -Verbose 4>&1
            }
            (-join $Output) | Should -BeLike '*PowerOn*true*'
        }
        
        It -Name 'Verify switch param - PowerOn:$false - Switch Param' -Test {
            $Output = & {
                New-RubrikHyperVVMMount -Id 'snapshotid' -PowerOn:$false -Verbose 4>&1
            }
            (-join $Output) | Should -BeLike '*PowerOn*false*'
        }
        
        It -Name 'Verify switch param - No PowerOn - Switch Param' -Test {
            $Output = & {
                New-RubrikHyperVVMMount -Id 'snapshotid' -Verbose 4>&1
            }
            (-join $Output) | Should -Not -BeLike '*PowerOn*'
        }
        
        It -Name 'Parameter id is missing' -Test {
            { New-RubrikHyperVVMMount -Id  } |
                Should -Throw "Missing an argument for parameter 'Id'. Specify a parameter of type 'System.String' and try again."
        }
        It -Name 'Parameter id is empty' -Test {
            { New-RubrikHyperVVMMount -id ''  } |
                Should -Throw "Cannot bind argument to parameter 'Id' because it is an empty string."
        }

        Assert-VerifiableMock
        Assert-MockCalled -CommandName Test-RubrikConnection -ModuleName 'Rubrik' -Exactly 10
        Assert-MockCalled -CommandName Submit-Request -ModuleName 'Rubrik'  -Exactly 10
    }
}