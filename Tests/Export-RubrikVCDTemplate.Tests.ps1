Remove-Module -Name 'Rubrik' -ErrorAction 'SilentlyContinue'
Import-Module -Name './Rubrik/Rubrik.psd1' -Force
Describe -Name 'Public/Export-RubrikVcdTemplate' -Tag 'Public', 'Export-RubrikVcdTemplate' -Fixture {
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
                    "name": "Templates",
                    "id": "VcdOrg:::01234567-8910-1abc-d435-0abc1234d567"
                  },
                  {
                    "name": "Templates",
                    "id": "VcdOrgVdc:::01234567-8910-1abc-d435-0abc1234d567"
                  },
                  {
                    "name": "Templates",
                    "id": "VcdCatalog:::01234567-8910-1abc-d435-0abc1234d567"
                  }
                ],
                "slaAssignment": "Direct",
                "effectiveSlaSourceObjectId": "VcdVapp:::01234567-8910-1abc-d435-0abc1234d567",
                "effectiveSlaSourceObjectName": "vAppTemplate",
                "catalogId": "01234567-8910-1abc-d435-0abc1234d567",
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
                "isTemplate": true,
                "isRelic": false,
                "name": "Template",
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
                  }
                ]
          }'
        $vapp = ConvertFrom-Json -InputObject $vappjson

        $result = @{
            'id'        = 'VCD_VAPP_EXPORT_01234567-8910-1abc-d435-0abc1234d567_01234567-8910-1abc-d435-0abc1234d567:::0'
            'status'    = 'QUEUED'
            'progress'  = '0'            
        }
        #endregion

        Context -Name 'Test script logic' {
            Mock -CommandName Get-RubrikVAppSnapshot -Verifiable -ModuleName 'Rubrik' -MockWith {
                return @{vappName = 'Template'}
            }
            Mock -CommandName Get-RubrikVApp -Verifiable -ModuleName 'Rubrik' -MockWith {
                return $vapp
            }
            Mock -CommandName Submit-Request -Verifiable -ModuleName 'Rubrik' -MockWith {
                return $result
            }

            It -Name 'Should run without error - Export to Template to Existing Catalog' -Test {
                ( Export-RubrikVcdTemplate -id '01234567-8910-1abc-d435-0abc1234d567' ).status |
                    Should -BeExactly 'QUEUED'
            }

            It -Name 'Should run without error - Export to Template to Alternate Catalog' -Test {
                ( Export-RubrikVcdTemplate -id '01234567-8910-1abc-d435-0abc1234d567' -catalogid 'VcdOrgVdc:::03b4c110-2d14-437f-a2b3-9458741ab20d' ).status |
                    Should -BeExactly 'QUEUED'
            }

            It -Name 'Should run without error - Export to Template to Alternate Catalog and set Name' -Test {
              ( Export-RubrikVcdTemplate -id '01234567-8910-1abc-d435-0abc1234d567' -catalogid 'VcdOrgVdc:::03b4c110-2d14-437f-a2b3-9458741ab20d' -Name 'Template02' ).status |
                  Should -BeExactly 'QUEUED'
          }
                        
            Assert-VerifiableMock
            Assert-MockCalled -CommandName Get-RubrikVApp -ModuleName 'Rubrik' -Exactly 3
            Assert-MockCalled -CommandName Submit-Request -ModuleName 'Rubrik' -Exactly 6

        }
        
        Context -Name 'Parameter Validation' {
            Mock -CommandName Submit-Request -Verifiable -ModuleName 'Rubrik' -MockWith {
                $true
            }
            
            It -Name 'Parameter ID cannot be $null' -Test {
                { Export-RubrikVcdTemplate -Id $null } |
                    Should -Throw "Cannot validate argument on parameter 'ID'"
            }
            It -Name 'Parameter ID cannot be empty' -Test {
                { Export-RubrikVcdTemplate -Id '' } |
                    Should -Throw "Cannot validate argument on parameter 'ID'"
            }
        }
    }
}
