Remove-Module -Name 'Rubrik' -ErrorAction 'SilentlyContinue'
Import-Module -Name './Rubrik/Rubrik.psd1' -Force

foreach ( $privateFunctionFilePath in ( Get-ChildItem -Path './Rubrik/Private' | Where-Object extension -eq '.ps1').FullName  ) {
    . $privateFunctionFilePath
}

Describe -Name 'Public/New-RubrikManagedVolumeExport' -Tag 'Public', 'New-RubrikManagedVolumeExport' -Fixture {
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
                'id'       = 'MANAGED_VOLUME_EXPORT_SNAPSHOT_11111'
                'status'   = 'QUEUED'
                'progress' = '0'
            }
        }

        It -Name 'Should newly created managed volume with QUEUED status' -Test {
            ( New-RubrikManagedVolumeExport -Id 'snapshotid').status |
                Should -BeExactly 'QUEUED'
        }
        
        It -Name 'Parameter id is missing' -Test {
            { New-RubrikManagedVolumeExport -Id  } |
                Should -Throw "Missing an argument for parameter 'Id'. Specify a parameter of type 'System.String' and try again."
        }
        It -Name 'Parameter id is empty' -Test {
            { New-RubrikManagedVolumeExport -id ''  } |
                Should -Throw "Cannot bind argument to parameter 'Id' because it is an empty string."
        }
        
        Assert-VerifiableMock
        Assert-MockCalled -CommandName Test-RubrikConnection -ModuleName 'Rubrik' -Times 1
        Assert-MockCalled -CommandName Submit-Request -ModuleName 'Rubrik'  -Times 1
    }
}