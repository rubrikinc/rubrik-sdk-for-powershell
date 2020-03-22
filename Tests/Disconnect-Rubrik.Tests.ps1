Remove-Module -Name 'Rubrik' -ErrorAction 'SilentlyContinue'
Import-Module -Name './Rubrik/Rubrik.psd1' -Force

foreach ( $privateFunctionFilePath in ( Get-ChildItem -Path './Rubrik/Private' | Where-Object extension -eq '.ps1').FullName  ) {
    . $privateFunctionFilePath
}

Describe -Name 'Public/Disconnect-Rubrik' -Tag 'Public', 'Disconnect-Rubrik' -Fixture {
    #region init
    $global:rubrikConnection = @{
        id       = 'test-id'
        userId   = 'test-userId'
        token    = 'test-token'
        server   = 'test-server'
        authType = 'Basic' 
        header   = @{ 'Authorization' = 'Bearer test-authorization' }
        time     = (Get-Date)
        api      = 'v1'
        version  = '5.0'
    }
    #endregion

    Context -Name 'Validate Connecting to Cluster' {
        Mock -CommandName Submit-Request -Verifiable -ModuleName 'Rubrik' -MockWith {
            [pscustomobject]@{
                id = 11111
                userId = 22222
                token = 33333
            }
        }

        It -Name 'Disconnect basic auth' -Test {
            {Disconnect-Rubrik} | 
                Should -Not -Throw
        }

        It -Name 'Disconnect with a Token' -Test {
            $rubrikConnection.authType = 'Token'
           $Output = Disconnect-Rubrik -Verbose 4>&1
           (-join $Output) | 
                Should -BeLike '*Detected token authentication - Disconnecting without deleting token.*'
        }

        Assert-VerifiableMock
        Assert-MockCalled -CommandName Submit-Request -ModuleName 'Rubrik' -Exactly 1
    }
}