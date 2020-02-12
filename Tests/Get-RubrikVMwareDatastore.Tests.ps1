Remove-Module -Name 'Rubrik' -ErrorAction 'SilentlyContinue'
Import-Module -Name './Rubrik/Rubrik.psd1' -Force

foreach ( $privateFunctionFilePath in ( Get-ChildItem -Path './Rubrik/Private' | Where-Object extension -eq '.ps1').FullName  ) {
    . $privateFunctionFilePath
}

Describe -Name 'Public/Get-RubrikVMwareDatastore' -Tag 'Public', 'Get-RubrikVMwareDatastore' -Fixture {
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
                'hasmore' = 'false'
                'total'   = '4'
                'data'    =
                    @{ 
                        'name'                   = 'datastore01'
                        'id'                     = 'Datastore:::11111'
                        'dataStoreType'          = 'NFS'
                    },
                    @{ 
                        'name'                   = 'datastore02'
                        'id'                     = 'Datastore:::22222'
                        'dataStoreType'          = 'VMFS'
                    },
                    @{ 
                        'name'                   = 'datastore03'
                        'id'                     = 'Datastore:::33333'
                        'dataStoreType'          = 'VMFS'
                    }
                    ,
                    @{ 
                        'name'                   = 'VSAN'
                        'id'                     = 'Datastore:::44444'
                        'dataStoreType'          = 'vsan'
                    }
            }
        }
        It -Name 'Should Return count of 4' -Test {
            ( Get-RubrikVMWareDatastore).Count |
                Should -BeExactly 4
        }
        It -Name 'Should Return datastore03' -Test {
            (Get-RubrikVMWareDatastore -name 'datastore03').Name |
                Should -BeExactly 'datastore03'
        }
        It -Name 'Should Return Datastore:::22222' -Test {
            ( Get-RubrikVMWareDatastore -name 'datastore02').id |
                Should -BeExactly 'Datastore:::22222'
        }
        It -Name 'Should return count of 2 ' -Test {
            (Get-RubrikVMwareDatastore -DatastoreType 'VMFS').count |
                Should -BeExactly 2
        }
        It -Name 'Should return count of 0 ' -Test {
            (Get-RubrikVMwareDatastore -Name 'test').count |
                Should -BeExactly 0
        }
        Assert-VerifiableMock
        Assert-MockCalled -CommandName Test-RubrikConnection -ModuleName 'Rubrik' -Times 1
        Assert-MockCalled -CommandName Submit-Request -ModuleName 'Rubrik' -Times 1
    }
