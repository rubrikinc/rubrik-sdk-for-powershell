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