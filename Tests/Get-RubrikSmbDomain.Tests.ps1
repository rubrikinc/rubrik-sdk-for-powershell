Remove-Module -Name 'Rubrik' -ErrorAction 'SilentlyContinue'
Import-Module -Name './Rubrik/Rubrik.psd1' -Force

foreach ( $privateFunctionFilePath in ( Get-ChildItem -Path './Rubrik/Private' | Where-Object extension -eq '.ps1').FullName  ) {
    . $privateFunctionFilePath
}

Describe -Name 'Public/Get-RubrikSmbDomain' -Tag 'Public', 'Get-RubrikSmbDomain' -Fixture {
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

    Context -Name 'Returned Results' {
        Mock -CommandName Test-RubrikConnection -Verifiable -ModuleName 'Rubrik' -MockWith { }
        Mock -CommandName Submit-Request -Verifiable -ModuleName 'Rubrik' -MockWith {
            @{
                'hasmore'   = 'false'
                'total'     = '1'
                'data'      =
                @{ 
                    'name'                  = 'domain.local'
                    'serviceAccount'        = 'serviceAccountUserName'
                    'isStickySmbService'    = 'true'
                    'status'                = 'Configured'
                },
                @{ 
                    'name'                  = 'anotherdomain.local'
                    'serviceAccount'        = 'serviceAccountUserName2'
                    'isStickySmbService'    = 'true'
                    'status'                = 'Configured'
                }
            }

        }
        It -Name 'No parameters returns all results' -Test {
            @( Get-RubrikSmbDomain).Count |
                Should -BeExactly 2
        }
        It -Name 'Name filter works' -Test {
            @(Get-RubrikSmbDomain -Name 'domain.local').serviceAccount | 
                Should -BeExactly 'serviceAccountUserName'
        }
        Assert-VerifiableMock
        Assert-MockCalled -CommandName Test-RubrikConnection -ModuleName 'Rubrik' -Exactly 2
        Assert-MockCalled -CommandName Submit-Request -ModuleName 'Rubrik' -Exactly 2
    }
}