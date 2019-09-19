Remove-Module -Name 'Rubrik' -ErrorAction 'SilentlyContinue'
Import-Module -Name './Rubrik/Rubrik.psd1' -Force
Describe -Name 'Public/Export-RubrikVApp' -Tag 'Public', 'Export-RubrikVApp' -Fixture {
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

        $vappjson = '{
                "isPaused": false,
                "vcdVmMoidsToExcludeFromSnapshot": [],
                "configuredSlaDomainName": "Silver",
                "effectiveSlaDomainId": "01234567-8910-1abc-d435-0abc1234d567",
                "primaryClusterId": "01234567-8910-1abc-d435-0abc1234d567",
                "infraPath": [
                  {
                    "name": "VMware vCloud Director",
                    "id": "Vcd:::01234567-8910-1abc-d435-0abc1234d567"
                  },
                  {
                    "name": "Tenant1",
                    "id": "VcdOrg:::01234567-8910-1abc-d435-0abc1234d567"
                  },
                  {
                    "name": "Tenant1a vDC",
                    "id": "VcdOrgVdc:::01234567-8910-1abc-d435-0abc1234d567"
                  }
                ],
                "slaAssignment": "Direct",
                "effectiveSlaSourceObjectId": "VcdVapp:::01234567-8910-1abc-d435-0abc1234d567",
                "effectiveSlaSourceObjectName": "vApp01",
                "vcdClusterName": "VMware vCloud Director",
                "vcdClusterId": "01234567-8910-1abc-d435-0abc1234d567",
                "configuredSlaDomainId": "01234567-8910-1abc-d435-0abc1234d567",
                "effectiveSlaDomainName": "Silver",
                "networks": [
                    {
                      "name": "network01",
                      "isDeployed": true
                    }
                  ],
                "isRelic": false,
                "name": "vApp01",
                "id": "VcdVapp:::01234567-8910-1abc-d435-0abc1234d567",
                "isBestEffortSynchronizationEnabled": true,
                "vms": [
                  {
                    "name": "vm01",
                    "vcdMoid": "vm-0a09772b-fc0f-466c-88d3-84d370012737",
                    "storagePolicyId": "7a9d26f0-bb4f-40e6-a76e-66c18d4b4917",
                    "networkConnections": [
                      {
                        "nicIndex": 0,
                        "macAddress": "00:50:56:01:00:24",
                        "addressingMode": "DHCP",
                        "vappNetworkName": "network01",
                        "isConnected": false
                      }
                    ]
                  },
                  {
                    "name": "vm02",
                    "vcdMoid": "vm-a5549267-3873-4c2d-a0b2-eafd4b01a682",
                    "storagePolicyId": "7a9d26f0-bb4f-40e6-a76e-66c18d4b4917",
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
                ]
          }'
        $vapp = ConvertFrom-Json -InputObject $vappjson  -Depth 8

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
        
        $vm = ConvertFrom-Json -InputObject $vmjson -Depth 3

        $result = @{
            'id'        = 'VCD_VAPP_EXPORT_01234567-8910-1abc-d435-0abc1234d567_01234567-8910-1abc-d435-0abc1234d567:::0'
            'status'    = 'QUEUED'
            'progress'  = '0'            
        }
        #endregion

        Context -Name 'Test script logic' {
            Mock -CommandName Get-RubrikVApp -Verifiable -ModuleName 'Rubrik' -MockWith {
                return $vapp
            }

            Mock -CommandName Submit-Request -Verifiable -ModuleName 'Rubrik' -MockWith {
                return $result
            }

            It -Name 'Should run without error - Partial Export to Existing Target vApp' -Test {
                ( Export-RubrikVApp -id '01234567-8910-1abc-d435-0abc1234d567' -snapshotid '01234567-8910-1abc-d435-0abc1234d567' -Partial $vm -ExportMode 'ExportToTargetVapp' -PowerOn:$false ).status |
                    Should -BeExactly 'QUEUED'
            }

            It -Name 'Should run without error - Partial Export to Alternate Target vApp' -Test {
                ( Export-RubrikVApp -id '01234567-8910-1abc-d435-0abc1234d567' -snapshotid '01234567-8910-1abc-d435-0abc1234d567' -Partial $vm -ExportMode 'ExportToTargetVapp' -TargetVAppID 'VcdVapp:::01234567-8910-1abc-d435-0abc1234d567' -PowerOn:$false ).status |
                    Should -BeExactly 'QUEUED'
            }

            It -Name 'Should run without error - Partial Export to New vApp' -Test {
                ( Export-RubrikVApp -id '01234567-8910-1abc-d435-0abc1234d567' -snapshotid '01234567-8910-1abc-d435-0abc1234d567' -Partial $vm -ExportMode 'ExportToNewVapp' -PowerOn:$false ).status |
                    Should -BeExactly 'QUEUED'
            }

            It -Name 'Should run without error - Full Restore to New vApp in Existing Org VDC' -Test {
                ( Export-RubrikVApp -id '01234567-8910-1abc-d435-0abc1234d567' -snapshotid '01234567-8910-1abc-d435-0abc1234d567' -ExportMode 'ExportToNewVapp' -PowerOn:$true ).status | 
                    Should -BeExactly 'QUEUED'
            }

            It -Name 'Should run without error - Full Restore to New vApp in Alternate Org VDC' -Test {
                ( Export-RubrikVApp -id '01234567-8910-1abc-d435-0abc1234d567' -snapshotid '01234567-8910-1abc-d435-0abc1234d567' -ExportMode 'ExportToNewVapp' -TargetOrgVDCID 'VcdOrgVdc:::01234567-8910-1abc-d435-0abc1234d567' -PowerOn:$true ).status | 
                    Should -BeExactly 'QUEUED'
            }

            It -Name 'Should run without error - Full Restore with RemoveNetworkDevices parameter' -Test {
                ( Export-RubrikVApp -id '01234567-8910-1abc-d435-0abc1234d567' -snapshotid '01234567-8910-1abc-d435-0abc1234d567' -ExportMode 'ExportToNewVapp' -PowerOn:$true -RemoveNetworkDevices).status | 
                    Should -BeExactly 'QUEUED'
            } 

            It -Name 'Should run without error - Full Restore with DisableNetwork parameter' -Test {
                ( Export-RubrikVApp -id '01234567-8910-1abc-d435-0abc1234d567' -snapshotid '01234567-8910-1abc-d435-0abc1234d567' -ExportMode 'ExportToNewVapp' -PowerOn:$true -DisableNetwork).status | 
                    Should -BeExactly 'QUEUED'
            } 
            
            It -Name 'Should run without error - Full Restore with NoMapping parameter' -Test {
                ( Export-RubrikVApp -id '01234567-8910-1abc-d435-0abc1234d567' -snapshotid '01234567-8910-1abc-d435-0abc1234d567' -ExportMode 'ExportToNewVapp' -PowerOn:$true -NoMapping).status | 
                    Should -BeExactly 'QUEUED'
            }

            It -Name 'Should run without error - Full Restore with NetworkMapping parameter' -Test {
                ( Export-RubrikVApp -id '01234567-8910-1abc-d435-0abc1234d567' -snapshotid '01234567-8910-1abc-d435-0abc1234d567' -ExportMode 'ExportToNewVapp' -PowerOn:$true -NetworkMapping 'network01').status | 
                    Should -BeExactly 'QUEUED'
            }
                        
            Assert-VerifiableMock
            Assert-MockCalled -CommandName Get-RubrikVApp -ModuleName 'Rubrik' -Exactly 7
            Assert-MockCalled -CommandName Submit-Request -ModuleName 'Rubrik' -Exactly 9

        }
        
        Context -Name 'ValidationScript of Partial Parameter' {
            Mock -CommandName Submit-Request -Verifiable -ModuleName 'Rubrik' -MockWith {
                $true
            }

            It -Name 'Empty Parital object should throw error' -Test {
                $empty = ''
                {(Export-RubrikVApp -id '01234567-8910-1abc-d435-0abc1234d567' -snapshotid '01234567-8910-1abc-d435-0abc1234d567' -Partial $empty -ExportMode 'ExportToNewVapp' -PowerOn:$false)} | 
                Should -Throw "Cannot validate argument on parameter 'Partial'. Partial parameter should be a PSCustomObject"
            }

            It -Name 'Missing name should throw error' -Test {
                $badrequest = $vm.PSObject.Copy()
                $badrequest.PSObject.Properties.Remove('name')
                {(Export-RubrikVApp -id '01234567-8910-1abc-d435-0abc1234d567' -snapshotid '01234567-8910-1abc-d435-0abc1234d567' -Partial $badrequest -ExportMode 'ExportToNewVapp' -PowerOn:$false)} | 
                Should -Throw "Cannot validate argument on parameter 'Partial'. Object passed via Partial parameter missing property name"
            }

            It -Name 'Missing vcdMoid should throw error' -Test {
                $badrequest = $vm.PSObject.Copy()
                $badrequest.PSObject.Properties.Remove('vcdMoid')
                {(Export-RubrikVApp -id '01234567-8910-1abc-d435-0abc1234d567' -snapshotid '01234567-8910-1abc-d435-0abc1234d567' -Partial $badrequest -ExportMode 'ExportToNewVapp' -PowerOn:$false)} | 
                Should -Throw "Cannot validate argument on parameter 'Partial'. Object passed via Partial parameter missing property vcdMoid"
            }

            It -Name 'Missing networkConnections should throw error' -Test {
                $badrequest = $vm.PSObject.Copy()
                $badrequest.PSObject.Properties.Remove('networkConnections')
                {(Export-RubrikVApp -id '01234567-8910-1abc-d435-0abc1234d567' -snapshotid '01234567-8910-1abc-d435-0abc1234d567' -Partial $badrequest -ExportMode 'ExportToNewVapp' -PowerOn:$false)} | 
                Should -Throw "Cannot validate argument on parameter 'Partial'. Object passed via Partial parameter missing property networkConnections"
            }

            It -Name 'Junk data should throw error' -Test {
                $badrequest = 'Junk data'
                {(Export-RubrikVApp -id '01234567-8910-1abc-d435-0abc1234d567' -snapshotid '01234567-8910-1abc-d435-0abc1234d567' -Partial $badrequest -ExportMode 'ExportToNewVapp' -PowerOn:$false)} | 
                Should -Throw "Cannot validate argument on parameter 'Partial'. Partial parameter should be a PSCustomObject"
            }
        }
        
        Context -Name 'Parameter Validation' {
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
            
            $vm = ConvertFrom-Json -InputObject $vmjson -Depth 3

            Mock -CommandName Submit-Request -Verifiable -ModuleName 'Rubrik' -MockWith {
                $true
            }
            
            It -Name 'Parameter ID cannot be $null' -Test {
                { Export-RubrikVApp -Id $null } |
                    Should -Throw "Cannot validate argument on parameter 'ID'"
            }
            It -Name 'Parameter ID cannot be empty' -Test {
                { Export-RubrikVApp -Id '' } |
                    Should -Throw "Cannot validate argument on parameter 'ID'"
            }
            It -Name 'Parameter Partial cannot be $null' -Test {
                { Export-RubrikVApp -Partial $null } |
                    Should -Throw "Cannot validate argument on parameter 'Partial'"
            }
            It -Name 'Parameter Partial cannot be empty' -Test {
                { Export-RubrikVApp -Partial '' } |
                    Should -Throw "Cannot validate argument on parameter 'Partial'"
            }
            It -Name 'Parameters TargetOrgVDCID and TargetVAppID cannot be simultaneously used' -Test {
                { Export-RubrikVApp -Id 01234567-8910-1abc-d435-0abc1234d567 -Partial $vm -PowerOn:$false -TargetOrgVDCID 'VcdOrgVdc:::01234567-8910-1abc-d435-0abc1234d567' -TargetVAppID 'VcdVapp:::01234567-8910-1abc-d435-0abc1234d567' } |
                    Should -Throw "Parameter set cannot be resolved using the specified named parameters."
            }
            It -Name 'Parameters Partial and DisableNetwork cannot be simultaneously used' -Test {
                { Export-RubrikVApp -Id 01234567-8910-1abc-d435-0abc1234d567 -PowerOn:$false -Partial $vm -DisableNetwork } |
                    Should -Throw "Parameter set cannot be resolved using the specified named parameters."
            }
            It -Name 'Parameters Partial and NoMapping cannot be simultaneously used' -Test {
                { Export-RubrikVApp -Id 01234567-8910-1abc-d435-0abc1234d567 -PowerOn:$false -Partial $vm -NoMapping } |
                    Should -Throw "Parameter set cannot be resolved using the specified named parameters."
            }
            It -Name 'Parameters Partial and RemoveNetworkDevices cannot be simultaneously used' -Test {
                { Export-RubrikVApp -Id 01234567-8910-1abc-d435-0abc1234d567 -PowerOn:$false -Partial $vm -RemoveNetworkDevices } |
                    Should -Throw "Parameter set cannot be resolved using the specified named parameters."
            }
            It -Name 'Parameters Partial and NetworkMapping cannot be simultaneously used' -Test {
                { Export-RubrikVApp -Id 01234567-8910-1abc-d435-0abc1234d567 -PowerOn:$false -Partial $vm -NetworkMapping 'Foo' } |
                    Should -Throw "Parameter set cannot be resolved using the specified named parameters."
            }
        }
    }
}