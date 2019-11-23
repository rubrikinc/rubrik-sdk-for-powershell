Remove-Module -Name 'Rubrik' -ErrorAction 'SilentlyContinue'
Import-Module -Name './Rubrik/Rubrik.psd1' -Force

foreach ( $privateFunctionFilePath in ( Get-ChildItem -Path './Rubrik/Private' | Where-Object extension -eq '.ps1').FullName  ) {
    . $privateFunctionFilePath
}

Describe -Name 'Public/Set-RubrikProxySetting' -Tag 'Public', 'Set-RubrikProxySetting' -Fixture {
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
            [pscustomobject]@{ 
                'host'     = 'proxy.server.com' 
                'protocol' = 'https'
            }
        }
        It -Name 'Set Rubrik Proxy Settings returns an object' -Test {
            @( Set-RubrikProxySetting -proxyhostname willreturnone -protocol HTTP | Measure-Object).Count |
                Should -BeExactly 1
        }
        It -Name 'Host is proxy.server.com' -Test {
            ( Set-RubrikProxySetting -proxyhostname 'proxy.server.com' -protocol SOCKS5).host |
                Should -BeExactly 'proxy.server.com'
        }        
        It -Name 'NodeIPAddress property is properly populated' -Test {
            (Set-RubrikProxySetting -IPAddress 10.10.10.10 -Host build.rubrik.com -Port 8080 -Protocol HTTPS).nodeipaddress |
                Should -BeExactly '10.10.10.10'
        }

        Assert-VerifiableMock
        Assert-MockCalled -CommandName Test-RubrikConnection -ModuleName 'Rubrik' -Exactly 3
        Assert-MockCalled -CommandName Submit-Request -ModuleName 'Rubrik' -Exactly 3
    }
    
    Context -Name 'Validate that protocol is case insensitive' {
        Mock -CommandName Test-RubrikConnection -Verifiable -ModuleName 'Rubrik' -MockWith { }
        Mock -CommandName Submit-Request -Verifiable -ModuleName 'Rubrik' -MockWith { }
        
        It -Name 'Verify Lowercase changed to upper case' -Test {
            $Output = & {
                Set-RubrikProxySetting -proxyhostname 'proxy.server.com' -protocol socks5 -Verbose 4>&1
            }
            (-join $Output) | Should -BeLikeExactly '*protocol*SOCKS5*'
        }
        
        It -Name 'Verify mixed case is changed to upper case' -Test {
            $Output = & {
                Set-RubrikProxySetting -proxyhostname 'proxy.server.com' -protocol HtTpS -Verbose 4>&1
            }
            (-join $Output) | Should -BeLikeExactly '*protocol*HTTPS*'
        }
        
        Assert-VerifiableMock
        Assert-MockCalled -CommandName Test-RubrikConnection -ModuleName 'Rubrik' -Exactly 2
        Assert-MockCalled -CommandName Submit-Request -ModuleName 'Rubrik' -Exactly 2
    }
    
    Context -Name 'Function should return correct object type' {
        Mock -CommandName Test-RubrikConnection -Verifiable -ModuleName 'Rubrik' -MockWith { }
        Mock -CommandName Submit-Request -Verifiable -ModuleName 'Rubrik' -MockWith {
            @{ 
                'host'     = 'proxy.server.com' 
                'protocol' = 'https'
            }
        }
        
        It -Name 'Should have a custom object type defined' -Test {
            (Set-RubrikProxySetting -proxyhostname 'proxy.server.com' -protocol SOCKS5).psobject.typenames |
                Should -Contain 'Rubrik.ProxySetting'
        }
        
        Assert-VerifiableMock
        Assert-MockCalled -CommandName Test-RubrikConnection -ModuleName 'Rubrik' -Exactly 1
        Assert-MockCalled -CommandName Submit-Request -ModuleName 'Rubrik' -Exactly 1
    }
}
