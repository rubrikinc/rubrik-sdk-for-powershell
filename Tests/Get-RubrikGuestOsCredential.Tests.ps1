Remove-Module -Name 'Rubrik' -ErrorAction 'SilentlyContinue'
Import-Module -Name './Rubrik/Rubrik.psd1' -Force

foreach ( $privateFunctionFilePath in ( Get-ChildItem -Path './Rubrik/Private' | Where-Object extension -eq '.ps1').FullName  ) {
    . $privateFunctionFilePath
}

Describe -Name 'Public/Get-RubrikGuestOSCredential' -Tag 'Public', 'Get-RubrikGuestOSCredential' -Fixture {
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
        Mock -CommandName Test-RubrikConnection -Verifiable -ModuleName 'Rubrik' -MockWith { }
        Mock -CommandName Submit-Request -Verifiable -ModuleName 'Rubrik' -MockWith {
            @{ 
                'username'  = 'user1'
                'id'        = '11111-22222-33333-44444-55555'
                'domain'    = 'domain.local'
            },
            @{ 
                'username'  = 'user2'
                'id'        = '11111-22222-33333-11111-55555'
                'domain'    = 'domain.local'
            },
            @{ 
                'username'  = 'user3'
                'id'        = '11111-11111-33333-44444-55555'
                'domain'    = 'anotherdomain.local'
            },
            @{ 
                'username'  = 'root'
                'id'        = '11111-22222-11111-44444-55555'
            }
        }
        It -Name 'Should Return count of 4' -Test {
            (Get-RubrikGuestOSCredential).Count |
                Should -BeExactly 4
        }
        It -Name 'Domain Filter should return count of 2' -Test {
            (Get-RubrikGuestOSCredential -Domain "domain.local").Count |
                Should -BeExactly 2
        }
        It -Name 'Username Filter works correctly' -Test {
            (Get-RubrikGuestOSCredential -Username "root").id |
                Should -BeExactly '11111-22222-11111-44444-55555'
        }
        It -Name 'Non existant user returns no results' -Test {
            (Get-RubrikGuestOSCredential -Username "nonexistant").id |
                Should -BeExactly $null
        }
        
        Assert-VerifiableMock
        Assert-MockCalled -CommandName Test-RubrikConnection -ModuleName 'Rubrik' -Exactly 4
        Assert-MockCalled -CommandName Submit-Request -ModuleName 'Rubrik' -Exactly 4
    }
}
