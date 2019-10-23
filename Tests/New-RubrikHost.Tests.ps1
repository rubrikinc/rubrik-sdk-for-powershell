Remove-Module -Name 'Rubrik' -ErrorAction 'SilentlyContinue'
Import-Module -Name './Rubrik/Rubrik.psd1' -Force

foreach ( $privateFunctionFilePath in ( Get-ChildItem -Path './Rubrik/Private' | Where-Object extension -eq '.ps1').FullName  ) {
    . $privateFunctionFilePath
}

Describe -Name 'Public/New-RubrikHost' -Tag 'Public', 'New-RubrikHost' -Fixture {
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

    Context -Name 'Reponse Validation' {
        Mock -CommandName Test-RubrikConnection -Verifiable -ModuleName 'Rubrik' -MockWith {}
        Mock -CommandName Submit-Request -Verifiable -ModuleName 'Rubrik' -MockWith {
            @{
                id = "11111-11111-11111"
                name = "MyNewServer.Rubrik.com"
                hostname = "MyNewServer.Rubrik.com"
                primaryClusterId = "22222-22222-22222"
                operatingSystem = "macOS"
            }
        }

        It -Name 'Should create new Rubrik host with correct name' -Test {
            ( New-RubrikHost -Name 'MyNewServer.Rubrik.com').Name |
                Should -BeExactly 'MyNewServer.Rubrik.com'
        }
        
        It -Name 'Should create new Rubrik host with correct hostname' -Test {
            ( New-RubrikHost -Name 'MyNewServer.Rubrik.com').hostname |
                Should -BeExactly 'MyNewServer.Rubrik.com'
        }
        
        It -Name 'Should create new Rubrik host with correct operating system' -Test {
            ( New-RubrikHost -Name 'MyNewServer.Rubrik.com').operatingSystem |
                Should -BeExactly 'macOS'
        }
        
        It -Name 'Verify switch param - No PauseBackups - Switch Param' -Test {
            $Output = & {
                New-RubrikHost -Name 'MyNewServer.Rubrik.com' -Verbose 4>&1
            }
            (-join $Output) | Should -BeLike '*hostname*:*MyNewServer.Rubrik.com*'
        }

        Assert-VerifiableMock
        Assert-MockCalled -CommandName Test-RubrikConnection -ModuleName 'Rubrik' -Exactly 4
        Assert-MockCalled -CommandName Submit-Request -ModuleName 'Rubrik'  -Exactly 4
    }
}