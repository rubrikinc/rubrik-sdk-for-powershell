Remove-Module -Name 'Rubrik' -ErrorAction 'SilentlyContinue'
Import-Module -Name './Rubrik/Rubrik.psd1' -Force

foreach ( $privateFunctionFilePath in ( Get-ChildItem -Path './Rubrik/Private' | Where-Object extension -eq '.ps1').FullName  ) {
    . $privateFunctionFilePath
}

Describe -Name 'Public/Get-RubrikProxySetting' -Tag 'Public', 'Get-RubrikProxySetting' -Fixture {
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
            [PSCustomObject]@{ 
                'host'     = 'proxy.server.com' 
                'protocol' = 'https'
            }
        }
        It -Name 'No parameters returns all results' -Test {
            @( Get-RubrikProxySetting | Measure-Object).Count |
                Should -BeExactly 1
        }
        It -Name 'Host is proxy.server.com' -Test {
            ( Get-RubrikProxySetting ).host |
                Should -BeExactly 'proxy.server.com'
        }
        
        It -Name 'NodeIPAddress property is properly populated' -Test {
            @( Get-RubrikProxySetting -IPAddress 10.10.10.10).nodeipaddress |
                Should -BeExactly '10.10.10.10'
        }

        Assert-VerifiableMock
        Assert-MockCalled -CommandName Test-RubrikConnection -ModuleName 'Rubrik' -Exactly 3
        Assert-MockCalled -CommandName Submit-Request -ModuleName 'Rubrik' -Exactly 3
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
            (Get-RubrikProxySetting).psobject.typenames |
                Should -Contain 'Rubrik.ProxySetting'
        }
        
        Assert-VerifiableMock
        Assert-MockCalled -CommandName Test-RubrikConnection -ModuleName 'Rubrik' -Exactly 1
        Assert-MockCalled -CommandName Submit-Request -ModuleName 'Rubrik' -Exactly 1
    }
}