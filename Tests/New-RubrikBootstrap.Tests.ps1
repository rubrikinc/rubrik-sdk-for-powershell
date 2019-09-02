Remove-Module -Name 'Rubrik' -ErrorAction 'SilentlyContinue'
Import-Module -Name './Rubrik/Rubrik.psd1' -Force

Describe -Name 'Public/New-RubrikBootstrap' -Tag 'Public', 'New-RubrikBootstrap' -Fixture {
    InModuleScope -ModuleName Rubrik -ScriptBlock {
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
        
        $BootStrapHash = @{
            name = 'rubrik-edge' 
            dnsNameservers = @('192.168.11.1')
            dnsSearchDomains = @('corp.us','branch.corp.us')
            ntpserverconfigs = @(@{server = 'pool.ntp.org'})
            adminUserInfo = @{emailAddress = 'nick@shoresmedia.com'; id ='admin'; password = 'P@SSw0rd!'}
            nodeconfigs = @{node1 = @{managementIpConfig = @{address = '192.168.11.1'; gateway = '192.168.11.100'; netmask = '255.255.255.0'}}}
        }
        #endregion

        Context -Name 'New Log Shipping Results' {
            Mock -CommandName Submit-Request -Verifiable -ModuleName 'Rubrik' -MockWith {
                $true
            }

            It -Name 'Should run without error' -Test {
                ( New-RubrikBootstrap @BootStrapHash ) | Should -BeExactly $true
            }
            
            Assert-VerifiableMock
            Assert-MockCalled -CommandName Submit-Request -ModuleName 'Rubrik'  -Exactly 1
        }
        Context -Name 'Parameter Validation' {
            # TODO
        }
    }
}