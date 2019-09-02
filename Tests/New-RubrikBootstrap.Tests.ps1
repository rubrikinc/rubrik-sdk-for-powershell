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

        Context -Name 'Test script logic' {
            Mock -CommandName Submit-Request -Verifiable -ModuleName 'Rubrik' -MockWith {
                $true
            }

            It -Name 'Should run without error' -Test {
                ( New-RubrikBootstrap @BootStrapHash ) | Should -BeExactly $true
            }
            
            Assert-VerifiableMock
            Assert-MockCalled -CommandName Submit-Request -ModuleName 'Rubrik' -Exactly 1
        }
        
        Context -Name 'ValidationScript of $nodeConfigs Parameter' {
            It -Name 'Empty nodeconfigs should throw error' -Test {
                $BootStrapHash.nodeconfigs = ''
                {(New-RubrikBootstrap @BootStrapHash)} | 
                Should -Throw "Cannot validate argument on parameter 'nodeConfigs'. The argument is null or empty. Provide an argument that is not null or empty, and then try the command again."
            }
            
            It -Name 'Junk data should throw error' -Test {
                $BootStrapHash.nodeconfigs = 'Junk data'
                {(New-RubrikBootstrap @BootStrapHash)} | 
                Should -Throw "node configuration should be a hashtable, refer to the documentation on how to structure a bootstrap request"
            }
            
            It -Name 'Incorrect address should throw error' -Test {
                $BootStrapHash.nodeconfigs = @{node1 = @{managementIpConfig = @{address = $null; gateway = '192.168.11.100'; netmask = '255.255.255.0'}}}
                {(New-RubrikBootstrap @BootStrapHash)} | 
                Should -Throw "Cannot validate argument on parameter 'nodeConfigs'. node configuration for node1 value address is null or empty"
            }
            
            It -Name 'Missing gateway should throw error' -Test {
                $BootStrapHash.nodeconfigs = @{node1 = @{managementIpConfig = @{address = '1.1.1.1'; netmask = '255.255.255.0'}}}
                {(New-RubrikBootstrap @BootStrapHash)} | 
                Should -Throw "Cannot validate argument on parameter 'nodeConfigs'. node configuration for node1 missing property gateway"
            }
        }
    }
}