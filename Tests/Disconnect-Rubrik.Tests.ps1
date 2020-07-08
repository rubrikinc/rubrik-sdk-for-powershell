Remove-Module -Name 'Rubrik' -ErrorAction 'SilentlyContinue'
Import-Module -Name './Rubrik/Rubrik.psd1' -Force

foreach ( $privateFunctionFilePath in ( Get-ChildItem -Path './Rubrik/Private' | Where-Object extension -eq '.ps1').FullName  ) {
    . $privateFunctionFilePath
}

Describe -Name 'Public/Disconnect-Rubrik' -Tag 'Public', 'Disconnect-Rubrik' -Fixture {
    #region init
    function Invoke-InitiateRubrikConnection {
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

        Invoke-InitiateRubrikConnection
        It -Name 'Disconnect basic auth' -Test {
            {Disconnect-Rubrik} | 
                Should -Not -Throw
        }

        It -Name 'Disconnect basic auth - Should Clean RubrikConnection' -Test {
            Invoke-InitiateRubrikConnection
            Disconnect-Rubrik

            $rubrikconnection | Should -BeNullOrEmpty  
        }

        It -Name 'Disconnect with a Token' -Test {
            Invoke-InitiateRubrikConnection
            $rubrikConnection.authType = 'Token'
            $Output = Disconnect-Rubrik -Verbose 4>&1
            (-join $Output) | 
                Should -BeLike '*Detected token authentication - Disconnecting without deleting token.*'
        }

        It -Name 'Disconnect with a Token - Should Clean RubrikConnection' -Test {
            Invoke-InitiateRubrikConnection
            $rubrikConnection.authType = 'Token'
            Disconnect-Rubrik

            $rubrikconnection | Should -BeNullOrEmpty  
        }

        Assert-VerifiableMock
        Assert-MockCalled -CommandName Submit-Request -ModuleName 'Rubrik' -Exactly 2
    }
}