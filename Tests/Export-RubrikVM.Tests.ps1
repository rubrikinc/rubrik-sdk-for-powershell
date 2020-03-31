Remove-Module -Name 'Rubrik' -ErrorAction 'SilentlyContinue'
Import-Module -Name './Rubrik/Rubrik.psd1' -Force

foreach ( $privateFunctionFilePath in ( Get-ChildItem -Path './Rubrik/Private' | Where-Object extension -eq '.ps1').FullName  ) {
    . $privateFunctionFilePath
}

Describe -Name 'Public/Export-RubrikVM' -Tag 'Public', 'Export-RubrikVM' -Fixture {
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

    Context -Name 'Switch Parameters' {
        Mock -CommandName Test-RubrikConnection -Verifiable -ModuleName 'Rubrik' -MockWith {}
        Mock -CommandName Submit-Request -Verifiable -ModuleName 'Rubrik' -MockWith {}
        
        It -Name 'Verify switch param - DisableNetwork:$true - Switch Param' -Test {
            $Output = & {
                Export-RubrikVM -id 1 -HostId 3 -DatastoreId 2 -DisableNetwork -Verbose 4>&1
            }
            (-join $Output) | Should -BeLike '*disableNetwork*true*'
        }
        
        It -Name 'Verify switch param - DisableNetwork:$false - Switch Param' -Test {
            $Output = & {
                Export-RubrikVM -id 1 -HostId 3 -DatastoreId 2 -DisableNetwork:$false -Verbose 4>&1
            }
            (-join $Output) | Should -BeLike '*disableNetwork*false*'
        }
        
        It -Name 'Verify switch param - No DisableNetwork - Switch Param' -Test {
            $Output = & {
                Export-RubrikVM -id 1 -HostId 3 -DatastoreId 2 -Verbose 4>&1
            }
            (-join $Output) | Should -Not -BeLike '*disableNetwork*'
        }
        
        It -Name 'Verify switch param - RemoveNetworkDevices:$true - Switch Param' -Test {
            $Output = & {
                Export-RubrikVM -id 1 -HostId 3 -DatastoreId 2 -RemoveNetworkDevices -Verbose 4>&1
            }
            (-join $Output) | Should -BeLike '*RemoveNetworkDevices*true*'
        }
        
        It -Name 'Verify switch param - RemoveNetworkDevices:$false - Switch Param' -Test {
            $Output = & {
                Export-RubrikVM -id 1 -HostId 3 -DatastoreId 2 -RemoveNetworkDevices:$false -Verbose 4>&1
            }
            (-join $Output) | Should -BeLike '*RemoveNetworkDevices*false*'
        }
        
        It -Name 'Verify switch param - No RemoveNetworkDevices - Switch Param' -Test {
            $Output = & {
                Export-RubrikVM -id 1 -HostId 3 -DatastoreId 2 -Verbose 4>&1
            }
            (-join $Output) | Should -Not -BeLike '*RemoveNetworkDevices*'
        }
        
        It -Name 'Verify switch param - KeepMACAddresses:$true - Switch Param' -Test {
            $Output = & {
                Export-RubrikVM -id 1 -HostId 3 -DatastoreId 2 -KeepMACAddresses -Verbose 4>&1
            }
            (-join $Output) | Should -BeLike '*KeepMACAddresses*true*'
        }
        
        It -Name 'Verify switch param - KeepMACAddresses:$false - Switch Param' -Test {
            $Output = & {
                Export-RubrikVM -id 1 -HostId 3 -DatastoreId 2 -KeepMACAddresses:$false -Verbose 4>&1
            }
            (-join $Output) | Should -BeLike '*KeepMACAddresses*false*'
        }
        
        It -Name 'Verify switch param - No KeepMACAddresses - Switch Param' -Test {
            $Output = & {
                Export-RubrikVM -id 1 -HostId 3 -DatastoreId 2 -Verbose 4>&1
            }
            (-join $Output) | Should -Not -BeLike '*KeepMACAddresses*'
        }
        
        It -Name 'Verify switch param - UnregisterVM:$true - Switch Param' -Test {
            $Output = & {
                Export-RubrikVM -id 1 -HostId 3 -DatastoreId 2 -UnregisterVM -Verbose 4>&1
            }
            (-join $Output) | Should -BeLike '*UnregisterVM*true*'
        }
        
        It -Name 'Verify switch param - UnregisterVM:$false - Switch Param' -Test {
            $Output = & {
                Export-RubrikVM -id 1 -HostId 3 -DatastoreId 2 -UnregisterVM:$false -Verbose 4>&1
            }
            (-join $Output) | Should -BeLike '*UnregisterVM*false*'
        }
        
        It -Name 'Verify switch param - No UnregisterVM - Switch Param' -Test {
            $Output = & {
                Export-RubrikVM -id 1 -HostId 3 -DatastoreId 2 -Verbose 4>&1
            }
            (-join $Output) | Should -Not -BeLike '*UnregisterVM*'
        }
        
        It -Name 'Verify switch param - PowerOn:$true - Switch Param' -Test {
            $Output = & {
                Export-RubrikVM -id 1 -HostId 3 -DatastoreId 2 -PowerOn -Verbose 4>&1
            }
            (-join $Output) | Should -BeLike '*PowerOn*true*'
        }
        
        It -Name 'Verify switch param - PowerOn:$false - Switch Param' -Test {
            $Output = & {
                Export-RubrikVM -id 1 -HostId 3 -DatastoreId 2 -PowerOn:$false -Verbose 4>&1
            }
            (-join $Output) | Should -BeLike '*PowerOn*false*'
        }
        
        It -Name 'Verify switch param - No PowerOn - Switch Param' -Test {
            $Output = & {
                Export-RubrikVM -id 1 -HostId 3 -DatastoreId 2 -Verbose 4>&1
            }
            (-join $Output) | Should -BeLike '*PowerOn*false*'
        }
        
        It -Name 'Verify switch param - RecoverTags:$true - Switch Param' -Test {
            $Output = & {
                Export-RubrikVM -id 1 -HostId 3 -DatastoreId 2 -RecoverTags -Verbose 4>&1
            }
            (-join $Output) | Should -BeLike '*RecoverTags*true*'
        }
        
        It -Name 'Verify switch param - RecoverTags:$false - Switch Param' -Test {
            $Output = & {
                Export-RubrikVM -id 1 -HostId 3 -DatastoreId 2 -RecoverTags:$false -Verbose 4>&1
            }
            (-join $Output) | Should -BeLike '*RecoverTags*false*'
        }
        
        It -Name 'Verify switch param - No RecoverTags - Switch Param' -Test {
            $Output = & {
                Export-RubrikVM -id 1 -HostId 3 -DatastoreId 2 -Verbose 4>&1
            }
            (-join $Output) | Should -Not -BeLike '*RecoverTags*'
        }
        
        Assert-VerifiableMock
        Assert-MockCalled -CommandName Test-RubrikConnection -ModuleName 'Rubrik' -Times 18
        Assert-MockCalled -CommandName Submit-Request -ModuleName 'Rubrik' -Times 18
    }
        
    Context -Name 'Parameters' {
        Mock -CommandName Test-RubrikConnection -Verifiable -ModuleName 'Rubrik' -MockWith {}
        Mock -CommandName Submit-Request -Verifiable -ModuleName 'Rubrik' -MockWith {
            @{
                'id'        = 'EXPORT_VMWARE_SNAPSHOT_11111'
                'status'    = 'QUEUED'
                'progress'  = '0'
            }
        }
        It -Name 'Should Return status of QUEUED' -Test {
            ( Export-RubrikVM -id 1 -HostId 3 -DatastoreId 2).status |
                Should -BeExactly 'QUEUED'
        }

        Context -Name 'Parameter Validation' {
            It -Name 'Parameter id cannot be $null or empty' -Test {
                { Export-RubrikVM -id $null } |
                    Should -Throw "Cannot bind argument to parameter 'id' because it is an empty string."
            }
            It -Name 'Parameter DatastoreId cannot be $null or empty' -Test {
                { Export-RubrikVM -id 1 -datastoreid $null } |
                    Should -Throw "Cannot bind argument to parameter 'datastoreid' because it is an empty string."
            }
        }
        Assert-VerifiableMock
        Assert-MockCalled -CommandName Test-RubrikConnection -ModuleName 'Rubrik' -Times 1
        Assert-MockCalled -CommandName Submit-Request -ModuleName 'Rubrik' -Times 1
    }
}