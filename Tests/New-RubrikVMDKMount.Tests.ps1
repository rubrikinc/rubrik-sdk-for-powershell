Remove-Module -Name 'Rubrik' -ErrorAction 'SilentlyContinue'
Import-Module -Name './Rubrik/Rubrik.psd1' -Force

foreach ( $privateFunctionFilePath in ( Get-ChildItem -Path './Rubrik/Private' | Where-Object extension -eq '.ps1').FullName  ) {
    . $privateFunctionFilePath
}

Describe -Name 'Public/New-RubrikVMDKMount' -Tag 'Public', 'New-RubrikVMDKMount' -Fixture {
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
    
    
    Context -Name 'Parameter/ID' {
        Mock -CommandName Test-RubrikConnection -Verifiable -ModuleName 'Rubrik' -MockWith {}
        Mock -CommandName Get-RubrikVM -Verifiable -ModuleName 'Rubrik' -MockWith {
            @{
                'id' = 'VirtualMachine:::aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee-vm-12345'
            }
        }
        Mock -CommandName Submit-Request -Verifiable -ModuleName 'Rubrik' -MockWith {
            @{ 
                'status' = 'QUEUED'
                'links' = @{
                    href = 'https://1.1.1.1/api/internal/vmware/vm/request/MOUNT_SNAPSHOT_8d4bf813-5b61-4074-bdbb-9f813d1e8456_f0579825-7e63-4686-ad0e-37606d980a69:::0'
                }
            }
        }
        It -Name 'Status should be QUEUED' -Test {
            ( New-RubrikVMDKMount -id '01234567-8910-1abc-d435-0abc1234d567' -TargetVM 'VM1' -AllDisks).status |
                Should -BeExactly 'QUEUED'
        }
        It -Name 'Mount request status should exist' -Test {
            ( New-RubrikVMDKMount -id '01234567-8910-1abc-d435-0abc1234d567' -TargetVM 'VM1' -AllDisks).links.href |
                Should -BeExactly 'https://1.1.1.1/api/internal/vmware/vm/request/MOUNT_SNAPSHOT_8d4bf813-5b61-4074-bdbb-9f813d1e8456_f0579825-7e63-4686-ad0e-37606d980a69:::0'
        }
        Assert-VerifiableMock
        Assert-MockCalled -CommandName Test-RubrikConnection -ModuleName 'Rubrik' -Times 1
        Assert-MockCalled -CommandName Submit-Request -ModuleName 'Rubrik' -Times 1
    }
    
    Context -Name 'Parameter Validation' {
        It -Name 'Parameter SnapshotID cannot be $null' -Test {
            { New-RubrikVMDKMount -SnapshotID $null } |
                Should -Throw "Cannot validate argument on parameter 'SnapshotID'"
        }
        It -Name 'Parameter SnapshotID cannot be empty' -Test {
            { New-RubrikVMDKMount -SnapshotID '' } |
                Should -Throw "Cannot validate argument on parameter 'SnapshotID'"
        }
        It -Name 'Parameter TargetVM cannot be $null' -Test {
            { New-RubrikVMDKMount -TargetVM $null } |
                Should -Throw "Cannot validate argument on parameter 'TargetVM'"
        }
        It -Name 'Parameter TargetVM cannot be empty' -Test {
            { New-RubrikVMDKMount -TargetVM '' } |
                Should -Throw "Cannot validate argument on parameter 'TargetVM'"
        }
    }
}