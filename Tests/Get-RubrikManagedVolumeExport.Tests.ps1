Remove-Module -Name 'Rubrik' -ErrorAction 'SilentlyContinue'
Import-Module -Name './Rubrik/Rubrik.psd1' -Force

foreach ( $privateFunctionFilePath in ( Get-ChildItem -Path './Rubrik/Private' | Where-Object extension -eq '.ps1').FullName  ) {
    . $privateFunctionFilePath
}

Describe -Name 'Public/Get-RubrikManagedVolumeExport' -Tag 'Public', 'Get-RubrikManagedVolumeExport' -Fixture {
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
                'total'     = '1'
                'hasMore'   = 'false'
                'data' =  
                @{
                    'id'                        = '11111-22222-33333'
                    'isActive'                  = 'True'
                    'primaryClusterId'          = 'local'
                    'sourceManagedVolumeName'   = 'OracleMV1'
                    'sourceManagedVolumeID'     = 'ManagedVolume:::11111'
                },
                @{
                    'id'                        = '22222-22222-33333'
                    'isActive'                  = 'True'
                    'primaryClusterId'          = 'local'
                    'sourceManagedVolumeName'   = 'OracleMV2'
                    'sourceManagedVolumeID'     = 'ManagedVolume:::11111'
                },
                @{
                    'id'                        = '33333-22222-33333'
                    'isActive'                  = 'True'
                    'primaryClusterId'          = 'local'
                    'sourceManagedVolumeName'   = 'SQLMV'
                    'sourceManagedVolumeID'     = 'ManagedVolume:::22222'
                }
            }
        }
        
        It -Name 'Getting all exports should return count of 3' -Test {
            (Get-RubrikManagedVolumeExport).Count |
                Should -BeExactly 3
        }
        It -Name 'Source name filter non existant name should return count of 0' -Test {
            (Get-RubrikManagedVolumeExport -SourceManagedVolumeName 'nonexistant').Count |
                Should -BeExactly 0
        } 
        It -Name 'Source name filter on individual name should return id of 33333-22222-33333' -Test {
            (Get-RubrikManagedVolumeExport -SourceManagedVolumeName 'SQLMV').id |
                Should -BeExactly '33333-22222-33333'
        } 
        It -Name 'Missing id value should throw exception' -Test {
            { Get-RubrikManagedVolumeExport -id  } |
                Should -Throw "Missing an argument for parameter 'id'. Specify a parameter of type 'System.String' and try again."
        } 
        
        Assert-VerifiableMock
        Assert-MockCalled -CommandName Test-RubrikConnection -ModuleName 'Rubrik' -Times 1
        Assert-MockCalled -CommandName Submit-Request -ModuleName 'Rubrik' -Times 1
    }

}