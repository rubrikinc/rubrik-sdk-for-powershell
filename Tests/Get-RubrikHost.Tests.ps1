Remove-Module -Name 'Rubrik' -ErrorAction 'SilentlyContinue'
Import-Module -Name './Rubrik/Rubrik.psd1' -Force

foreach ( $privateFunctionFilePath in ( Get-ChildItem -Path './Rubrik/Private' | Where-Object extension -eq '.ps1').FullName  ) {
    . $privateFunctionFilePath
}

Describe -Name 'Public/Get-RubrikHost' -Tag 'Public', 'Get-RubrikHost' -Fixture {
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
                'name'                   = 'host01'
                'id'                     = 'Host:::11111'
                'operatingSystemType'    = 'Windows'
            },
            @{ 
                'name'                   = 'host02'
                'id'                     = 'Host:::22222'
                'operatingSystemType'    = 'Windows'
            },
            @{ 
                'name'                   = 'host03'
                'id'                     = 'Host:::33333'
                'operatingSystemType'    = 'Linux'
            },
            @{ 
                'name'                   = 'host04'
                'id'                     = 'Host:::44444'
                'operating_system_type'  = 'Windows'
            },
            @{ 
                'name'                   = 'host05'
                'id'                     = 'Host:::55555'
                'operating_system_type'  = 'Linux'
            }
        }
        It -Name 'Should Return count of 5' -Test {
            ( Get-RubrikHost).Count |
                Should -BeExactly 5
        }
        It -Name 'Should Return host05' -Test {
            (Get-RubrikHost -Name 'host05').Name |
                Should -BeExactly 'host05'
        }
        It -Name 'Should Return Host:::22222' -Test {
            ( Get-RubrikHost -name 'host02').id |
                Should -BeExactly 'Host:::22222'
        }
        It -Name 'Should return count of 0 ' -Test {
            (Get-RubrikHost -Name 'nonexistant').count |
                Should -BeExactly 0
        }
        Assert-VerifiableMock
        Assert-MockCalled -CommandName Test-RubrikConnection -ModuleName 'Rubrik' -Times 1
        Assert-MockCalled -CommandName Submit-Request -ModuleName 'Rubrik' -Times 1
    }
}