Remove-Module -Name 'Rubrik' -ErrorAction 'SilentlyContinue'
Import-Module -Name './Rubrik/Rubrik.psd1' -Force

foreach ( $privateFunctionFilePath in ( Get-ChildItem -Path './Rubrik/Private' | Where-Object extension -eq '.ps1').FullName  ) {
    . $privateFunctionFilePath
}

Describe -Name 'Public/Get-RubrikVolumeGroupMount' -Tag 'Public', 'Get-RubrikVolumeGroupMount' -Fixture {
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
                'hasmore'   = 'false'
                'total'     = '4'
                'data'      =
                @{ 
                    'name'                   = 'mount01'
                    'id'                     = '11111'
                    'sourceVolumeGroupId'    = 'VolumeGroup:::11111'
                    'sourceHostId'           = 'host:::11111'
                    'sourceHostName'         = 'host01'
                },
                @{ 
                    'name'                   = 'mount01'
                    'id'                     = '22222'
                    'sourceVolumeGroupId'    = 'VolumeGroup:::11111'
                    'sourceHostId'           = 'host:::11111'
                    'sourceHostName'         = 'host01'
                },
                @{ 
                    'name'                   = 'mount02'
                    'id'                     = '33333'
                    'sourceVolumeGroupId'    = 'VolumeGroup:::22222'
                    'sourceHostId'           = 'host:::22222'
                    'sourceHostName'         = 'host02'
                },
                @{ 
                    'name'                   = 'mount03'
                    'id'                     = '44444'
                    'sourceVolumeGroupId'    = 'VolumeGroup:::33333'
                    'sourceHostId'           = 'host:::33333'
                    'sourceHostName'         = 'host03'
                }
            }
        }
        It -Name 'Requesting all should return count of 4' -Test {
            ( Get-RubrikVolumeGroupMount).Count |
                Should -BeExactly 4
        }                       
        It -Name 'Missing ID Exception' -Test {
            { Get-RubrikVolumeGroupMount -id  } |
                Should -Throw "Missing an argument for parameter 'id'. Specify a parameter of type 'System.String' and try again."
        } 
        It -Name 'Missing Source Host Exception' -Test {
            { Get-RubrikVolumeGroupMount -source_host  } |
                Should -Throw "Missing an argument for parameter 'source_host'. Specify a parameter of type 'System.String' and try again."
        } 

        Assert-VerifiableMock
        Assert-MockCalled -CommandName Test-RubrikConnection -ModuleName 'Rubrik' -Times 1
        Assert-MockCalled -CommandName Submit-Request -ModuleName 'Rubrik' -Times 1
    }
}