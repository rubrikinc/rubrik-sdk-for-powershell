Remove-Module -Name 'Rubrik' -ErrorAction 'SilentlyContinue'
Import-Module -Name './Rubrik/Rubrik.psd1' -Force

$result = @{
    'id'        = 'VCD_VAPP_RESTORE_01234567-8910-1abc-d435-0abc1234d567_01234567-8910-1abc-d435-0abc1234d567:::0'
    'status'    = 'QUEUED'
    'progress'  = '0'            
}

Describe -Name 'Public/Restore-RubrikVApp' -Tag 'Public', 'Restore-RubrikVApp' -Fixture {
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

        $recoveroptsjson = '{
            "restorableVms": [
              {
                "name": "vApp01",
                "vcdMoid": "vm-0609c47f-1c9f-4928-a18a-36815a55885f",
                "networkConnections": [
                  {
                    "nicIndex": 0,
                    "macAddress": "00:50:56:01:00:24",
                    "addressingMode": "DHCP",
                    "vappNetworkName": "network01",
                    "isConnected": true
                  }
                ]
              },
              {
                "name": "vApp02",
                "vcdMoid": "vm-a5549267-3873-4c2d-a0b2-eafd4b01a682",
                "networkConnections": [
                  {
                    "nicIndex": 0,
                    "macAddress": "00:50:56:01:00:64",
                    "addressingMode": "DHCP",
                    "vappNetworkName": "network01",
                    "isConnected": true
                  }
                ]
              }
            ],
            "availableVappNetworks": [
              {
                "name": "network01",
                "isDeployed": true
              },
              {
                "name": "network02",
                "parentNetworkId": "01234567-8910-1abc-d435-0abc1234d567",
                "isDeployed": true
              }
            ]
          }'
        $recoveropts = ConvertFrom-Json -InputObject $recoveroptsjson 

        $vmjson = '{
            "name": "vApp01",
            "vcdMoid": "vm-0609c47f-1c9f-4928-a18a-36815a55885f",
            "networkConnections": [
              {
                "nicIndex": 0,
                "addressingMode": "DHCP",
                "ipAddress": "192.168.1.103",
                "vappNetworkName": "network01",
                "isConnected": true
              }
            ]
          }'
        
        $vm = ConvertFrom-Json -InputObject $vmjson

        $result = @{
            'id'        = 'VCD_REFRESH_01234567-8910-1abc-d435-0abc1234d567_01234567-8910-1abc-d435-0abc1234d567:::0'
            'status'    = 'QUEUED'
            'progress'  = '0'            
        }
        #endregion

        Context -Name 'Test script logic' {
            Mock -CommandName Get-RubrikVAppRecoverOption -Verifiable -ModuleName 'Rubrik' -MockWith {
                return $recoveropts
            }

            Mock -CommandName Submit-Request -Verifiable -ModuleName 'Rubrik' -MockWith {
                return $result
            }

            It -Name 'Should run without error - Partial Restore' -Test {
                ( Restore-RubrikVApp -id '01234567-8910-1abc-d435-0abc1234d567' -Partial $vm -PowerOn:$false ).status |
                    Should -BeExactly 'QUEUED'
            }

            It -Name 'Should run without error - Full Restore' -Test {
                ( Restore-RubrikVApp -id '01234567-8910-1abc-d435-0abc1234d567' -PowerOn:$true ).status | 
                    Should -BeExactly 'QUEUED'
            }

            It -Name 'Should run without error - NetworkMapping' -Test {
                ( Restore-RubrikVApp -id '01234567-8910-1abc-d435-0abc1234d567' -PowerOn:$true -NetworkMapping 'network01').status | 
                    Should -BeExactly 'QUEUED'
            }
                        
            Assert-VerifiableMock
            Assert-MockCalled -CommandName Get-RubrikVAppRecoverOption -ModuleName 'Rubrik' -Exactly 2
            Assert-MockCalled -CommandName Submit-Request -ModuleName 'Rubrik' -Exactly 3

        }
        
        Context -Name 'ValidationScript of Partial Parameter' {
            Mock -CommandName Submit-Request -Verifiable -ModuleName 'Rubrik' -MockWith {
                $true
            }

            It -Name 'Empty Parital object should throw error' -Test {
                $empty = ''
                {(Restore-RubrikVApp -id '01234567-8910-1abc-d435-0abc1234d567' -Partial $empty -PowerOn:$false)} | 
                Should -Throw "Cannot validate argument on parameter 'Partial'. Partial parameter should be a PSCustomObject"
            }

            It -Name 'Missing name should throw error' -Test {
                $badrequest = $vm.PSObject.Copy()
                $badrequest.PSObject.Properties.Remove('name')
                {(Restore-RubrikVApp -id '01234567-8910-1abc-d435-0abc1234d567' -Partial $badrequest -PowerOn:$false)} | 
                Should -Throw "Cannot validate argument on parameter 'Partial'. Object passed via Partial parameter missing property name"
            }

            It -Name 'Missing vcdMoid should throw error' -Test {
                $badrequest = $vm.PSObject.Copy()
                $badrequest.PSObject.Properties.Remove('vcdMoid')
                {(Restore-RubrikVApp -id '01234567-8910-1abc-d435-0abc1234d567' -Partial $badrequest -PowerOn:$false)} | 
                Should -Throw "Cannot validate argument on parameter 'Partial'. Object passed via Partial parameter missing property vcdMoid"
            }

            It -Name 'Missing networkConnections should throw error' -Test {
                $badrequest = $vm.PSObject.Copy()
                $badrequest.PSObject.Properties.Remove('networkConnections')
                {(Restore-RubrikVApp -id '01234567-8910-1abc-d435-0abc1234d567' -Partial $badrequest -PowerOn:$false)} | 
                Should -Throw "Cannot validate argument on parameter 'Partial'. Object passed via Partial parameter missing property networkConnections"
            }

            It -Name 'Junk data should throw error' -Test {
                $badrequest = 'Junk data'
                {(Restore-RubrikVApp -id '01234567-8910-1abc-d435-0abc1234d567' -Partial $badrequest -PowerOn:$false)} | 
                Should -Throw "Cannot validate argument on parameter 'Partial'. Partial parameter should be a PSCustomObject"
            }
        }
        

        Context -Name 'Parameter Validation' {
            It -Name 'Parameter ID cannot be $null' -Test {
                { Restore-RubrikVApp -Id $null } |
                    Should -Throw "Cannot validate argument on parameter 'ID'"
            }
            It -Name 'Parameter ID cannot be empty' -Test {
                { Restore-RubrikVApp -Id '' } |
                    Should -Throw "Cannot validate argument on parameter 'ID'"
            }
            It -Name 'Parameter Partial cannot be $null' -Test {
                { Restore-RubrikVApp -Partial $null } |
                    Should -Throw "Cannot validate argument on parameter 'Partial'"
            }
            It -Name 'Parameter Partial cannot be empty' -Test {
                { Restore-RubrikVApp -Partial '' } |
                    Should -Throw "Cannot validate argument on parameter 'Partial'"
            }
            It -Name 'Parameters Partial and DisableNetwork cannot be simultaneously used' -Test {
                { Restore-RubrikVApp -Id 01234567-8910-1abc-d435-0abc1234d567 -PowerOn:$false -Partial $vm -DisableNetwork } |
                    Should -Throw "Parameter set cannot be resolved using the specified named parameters."
            }
            It -Name 'Parameters Partial and NoMapping cannot be simultaneously used' -Test {
                { Restore-RubrikVApp -Id 01234567-8910-1abc-d435-0abc1234d567 -PowerOn:$false -Partial $vm -NoMapping } |
                    Should -Throw "Parameter set cannot be resolved using the specified named parameters."
            }
            It -Name 'Parameters Partial and RemoveNetworkDevices cannot be simultaneously used' -Test {
                { Restore-RubrikVApp -Id 01234567-8910-1abc-d435-0abc1234d567 -PowerOn:$false -Partial $vm -RemoveNetworkDevices } |
                    Should -Throw "Parameter set cannot be resolved using the specified named parameters."
            }
            It -Name 'Parameters Partial and NetworkMapping cannot be simultaneously used' -Test {
                { Restore-RubrikVApp -Id 01234567-8910-1abc-d435-0abc1234d567 -PowerOn:$false -Partial $vm -NetworkMapping 'Foo' } |
                    Should -Throw "Parameter set cannot be resolved using the specified named parameters."
            }
        }

    }
}