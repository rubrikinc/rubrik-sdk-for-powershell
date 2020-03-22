Remove-Module -Name 'Rubrik' -ErrorAction 'SilentlyContinue'
Import-Module -Name './Rubrik/Rubrik.psd1' -Force

foreach ( $privateFunctionFilePath in ( Get-ChildItem -Path './Rubrik/Private' | Where-Object extension -eq '.ps1').FullName  ) {
    . $privateFunctionFilePath
}

Describe -Name 'Public/Connect-Rubrik' -Tag 'Public', 'Connect-Rubrik' -Fixture {
    #region init
    $global:rubrikConnection = @{
        id      = 'test-id'
        userId  = 'test-userId'
        token   = 'test-token'
        server  = 'test-server'
        header  = @{ 'Authorization' = 'Bearer test-authorization' }
        time    = (Get-Date)
        api     = 'v1'
        version = '5.0'
    }
    #endregion

    Context -Name 'Validate Connecting to Cluster' {
        Mock -CommandName Get-RubrikAPIVersion -Verifiable -ModuleName 'Rubrik' -MockWith { }
        Mock -CommandName Get-RubrikSoftwareVersion -Verifiable -ModuleName 'Rubrik' -MockWith {
            '5.1.2-8188'
        }
        Mock -CommandName New-UserAgentString -Verifiable -ModuleName 'Rubrik' -MockWith { }
        Mock -CommandName Submit-Request -Verifiable -ModuleName 'Rubrik' -MockWith {
            [pscustomobject]@{
                id = 11111
                userId = 22222
                token = 33333
            }
        }
        It -Name 'Username / Password combination' -Test {
            (Connect-Rubrik -Server testcluster -Username jaapbrasser -Password $(ConvertTo-SecureString -String password -AsPlainText -Force)) | Out-String |
                Should -BeLikeExactly '*Basic*'
        }

        It -Name 'Credential Object' -Test {
            $SecurePW = ConvertTo-SecureString -String password -AsPlainText -Force
            $Cred = New-Object System.Management.Automation.PSCredential ('jaapbrasser', $SecurePW)

            (Connect-Rubrik -Server testcluster -Credential $Cred) | Out-String |
                Should -BeLikeExactly '*Basic*'
        }

        It -Name 'API Token' -Test {
            (Connect-Rubrik -Server testcluster -Token 33333) | Out-String |
                Should -BeLikeExactly '*Token*'
        }

        It -Name 'RubrikConnections array should contain 3 entries' -Test {
            @($RubrikConnections).Count | 
                Should -Be 3
        }

        Assert-VerifiableMock
        Assert-MockCalled -CommandName Submit-Request -ModuleName 'Rubrik' -Exactly 3
    }
}