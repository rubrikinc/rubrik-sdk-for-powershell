Remove-Module -Name 'Rubrik' -ErrorAction 'SilentlyContinue'
Import-Module -Name './Rubrik/Rubrik.psd1' -Force

foreach ( $privateFunctionFilePath in ( Get-ChildItem -Path './Rubrik/Private' | Where-Object extension -eq '.ps1').FullName  ) {
    . $privateFunctionFilePath
}

Describe -Name 'Public/Get-RubrikVApp' -Tag 'Public', 'Get-RubrikVApp' -Fixture {
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

    Context -Name 'Parameters' {
        Mock -CommandName Test-RubrikConnection -Verifiable -ModuleName 'Rubrik' -MockWith {}
        Mock -CommandName Submit-Request -Verifiable -ModuleName 'Rubrik' -MockWith {
            $response = '{
                "hasMore": false,
                "data": [
                  {
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
                    "isRelic": false,
                    "name": "vApp01",
                    "id": "VcdVapp:::01234567-8910-1abc-d435-0abc1234d567"
                  },
                  {
                    "configuredSlaDomainName": "Inherit",
                    "effectiveSlaDomainId": "UNPROTECTED",
                    "primaryClusterId": "01234567-8910-1abc-d435-0abc1234d567",
                    "infraPath": [
                      {
                        "name": "VMware vCloud Director",
                        "id": "Vcd:::01234567-8910-1abc-d435-0abc1234d567"
                      },
                      {
                        "name": "Tenant2",
                        "id": "VcdOrg:::01234567-8910-1abc-d435-0abc1234d568"
                      },
                      {
                        "name": "Tenant2 vDC",
                        "id": "VcdOrgVdc:::01234567-8910-1abc-d435-0abc1234d568"
                      }
                    ],
                    "slaAssignment": "Unassigned",
                    "effectiveSlaSourceObjectId": "Global:::All",
                    "vcdClusterName": "VMware vCloud Director",
                    "vcdClusterId": "01234567-8910-1abc-d435-0abc1234d567",
                    "configuredSlaDomainId": "INHERIT",
                    "effectiveSlaDomainName": "Unprotected",
                    "isRelic": false,
                    "name": "vApp02-Tue Aug 27 2019 14:55:37 GMT-0700 (Pacific Daylight Time)",
                    "id": "VcdVapp:::01234567-8910-1abc-d435-0abc1234d568"
                  },
                  {
                    "configuredSlaDomainName": "Bronze",
                    "effectiveSlaDomainId": "01234567-8910-1abc-d435-0abc1234d568",
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
                        "name": "Tenant1b vDC",
                        "id": "VcdOrgVdc:::01234567-8910-1abc-d435-0abc1234d569"
                      }
                    ],
                    "slaAssignment": "Direct",
                    "effectiveSlaSourceObjectId": "VcdVapp:::01234567-8910-1abc-d435-0abc1234d569",
                    "effectiveSlaSourceObjectName": "vApp03",
                    "vcdClusterName": "VMware vCloud Director",
                    "vcdClusterId": "01234567-8910-1abc-d435-0abc1234d567",
                    "configuredSlaDomainId": "01234567-8910-1abc-d435-0abc1234d568",
                    "effectiveSlaDomainName": "Bronze",
                    "isRelic": false,
                    "name": "vApp03",
                    "id": "VcdVapp:::01234567-8910-1abc-d435-0abc1234d569"
                  },
                  {
                    "configuredSlaDomainName": "Bronze",
                    "effectiveSlaDomainId": "01234567-8910-1abc-d435-0abc1234d568",
                    "primaryClusterId": "01234567-8910-1abc-d435-0abc1234d567",
                    "infraPath": [
                      {
                        "name": "VMware vCloud Director",
                        "id": "Vcd:::01234567-8910-1abc-d435-0abc1234d567"
                      },
                      {
                        "name": "Tenant2",
                        "id": "VcdOrg:::01234567-8910-1abc-d435-0abc1234d568"
                      },
                      {
                        "name": "Tenant2 vDC",
                        "id": "VcdOrgVdc:::01234567-8910-1abc-d435-0abc1234d568"
                      }
                    ],
                    "slaAssignment": "Direct",
                    "effectiveSlaSourceObjectId": "VcdVapp:::01234567-8910-1abc-d435-0abc1234d570",
                    "effectiveSlaSourceObjectName": "vApp 04",
                    "vcdClusterName": "VMware vCloud Director",
                    "vcdClusterId": "01234567-8910-1abc-d435-0abc1234d567",
                    "configuredSlaDomainId": "01234567-8910-1abc-d435-0abc1234d568",
                    "effectiveSlaDomainName": "Bronze",
                    "isRelic": false,
                    "name": "vApp 04",
                    "id": "VcdVapp:::01234567-8910-1abc-d435-0abc1234d570"
                  }
                ],
                "total": 4
              }'
            return ConvertFrom-Json $response
        }

        It -Name 'filtering on Silver SLA should return one result' -Test {
            Mock -CommandName Get-RubrikSLA -Verifiable -ModuleName 'Rubrik' -MockWith {
                @{ 'id' = '01234567-8910-1abc-d435-0abc1234d567' }
            }

            ( Get-RubrikVApp -SLA 'Silver' ).Name |
                Should -BeExactly "vApp01"
        }

        It -Name 'filtering on Bronze SLA should return two results' -Test {
            Mock -CommandName Get-RubrikSLA -Verifiable -ModuleName 'Rubrik' -MockWith {
                @{ 'id' = '01234567-8910-1abc-d435-0abc1234d568' }
            }

            ( Get-RubrikVApp -SLA 'Bronze' ).Length |
                Should -BeExactly 2
        }

        It -Name 'filtering on Name should return one result' -Test {
            ( Get-RubrikVApp -Name 'vApp01' ).id |
                Should -BeExactly "VcdVapp:::01234567-8910-1abc-d435-0abc1234d567"
        }

        It -Name 'filtering on SourceObjectId should return one result' -Test {
            ( Get-RubrikVApp -SourceObjectId 'VcdVapp:::01234567-8910-1abc-d435-0abc1234d570' ).name |
                Should -BeExactly "vApp 04"
        }

        It -Name 'filtering on SourceObjectName should return one result' -Test {
            ( Get-RubrikVApp -SourceObjectName 'vApp03' ).id |
                Should -BeExactly "VcdVapp:::01234567-8910-1abc-d435-0abc1234d569"
        }

        It -Name 'filtering on Relics only should return one result' -Test {
            Mock -CommandName Submit-Request -Verifiable -ModuleName 'Rubrik' -MockWith {
                $response = '{
                    "hasMore": false,
                    "data": [
                        {
                            "configuredSlaDomainName": "Inherit",
                            "effectiveSlaDomainId": "UNPROTECTED",
                            "primaryClusterId": "01234567-8910-1abc-d435-0abc1234d567",
                            "infraPath": [
                              {
                                "name": "VMware vCloud Director",
                                "id": "Vcd:::01234567-8910-1abc-d435-0abc1234d567"
                              },
                              {
                                "name": "Tenant2",
                                "id": "VcdOrg:::01234567-8910-1abc-d435-0abc1234d568"
                              },
                              {
                                "name": "Tenant2 vDC",
                                "id": "VcdOrgVdc:::01234567-8910-1abc-d435-0abc1234d568"
                              }
                            ],
                            "slaAssignment": "Unassigned",
                            "effectiveSlaSourceObjectId": "Global:::All",
                            "vcdClusterName": "VMware vCloud Director",
                            "vcdClusterId": "01234567-8910-1abc-d435-0abc1234d567",
                            "configuredSlaDomainId": "INHERIT",
                            "effectiveSlaDomainName": "Unprotected",
                            "isRelic": false,
                            "name": "vApp02-Tue Aug 27 2019 14:55:37 GMT-0700 (Pacific Daylight Time)",
                            "id": "VcdVapp:::01234567-8910-1abc-d435-0abc1234d568"
                        }
                    ],
                    "total": 1
                  }'
                return ConvertFrom-Json $response
            }
            
            ( Get-RubrikVApp -Relic ).id |
                Should -BeExactly "VcdVapp:::01234567-8910-1abc-d435-0abc1234d568"
        }

        It -Name 'filtering on Silver SLA ID should return one result' -Test {
            Mock -CommandName Submit-Request -Verifiable -ModuleName 'Rubrik' -MockWith {
                $response = '{
                    "hasMore": false,
                    "data": [
                      {
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
                        "isRelic": false,
                        "name": "vApp01",
                        "id": "VcdVapp:::01234567-8910-1abc-d435-0abc1234d567"
                      }
                    ],
                    "total": 1
                  }'
                return ConvertFrom-Json $response
            }
            ( Get-RubrikVApp -SLAID '01234567-8910-1abc-d435-0abc1234d567' ).Name |
                Should -BeExactly "vApp01"
        }

        It -Name 'filtering on Bronze SLA ID should return two results' -Test {
            Mock -CommandName Submit-Request -Verifiable -ModuleName 'Rubrik' -MockWith {
                $response = '{
                    "hasMore": false,
                    "data": [
                      {
                        "configuredSlaDomainName": "Bronze",
                        "effectiveSlaDomainId": "01234567-8910-1abc-d435-0abc1234d568",
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
                            "name": "Tenant1b vDC",
                            "id": "VcdOrgVdc:::01234567-8910-1abc-d435-0abc1234d569"
                          }
                        ],
                        "slaAssignment": "Direct",
                        "effectiveSlaSourceObjectId": "VcdVapp:::01234567-8910-1abc-d435-0abc1234d569",
                        "effectiveSlaSourceObjectName": "vApp02",
                        "vcdClusterName": "VMware vCloud Director",
                        "vcdClusterId": "01234567-8910-1abc-d435-0abc1234d567",
                        "configuredSlaDomainId": "01234567-8910-1abc-d435-0abc1234d568",
                        "effectiveSlaDomainName": "Bronze",
                        "isRelic": false,
                        "name": "vApp03",
                        "id": "VcdVapp:::01234567-8910-1abc-d435-0abc1234d569"
                      },
                      {
                        "configuredSlaDomainName": "Bronze",
                        "effectiveSlaDomainId": "01234567-8910-1abc-d435-0abc1234d568",
                        "primaryClusterId": "01234567-8910-1abc-d435-0abc1234d567",
                        "infraPath": [
                          {
                            "name": "VMware vCloud Director",
                            "id": "Vcd:::01234567-8910-1abc-d435-0abc1234d567"
                          },
                          {
                            "name": "Tenant2",
                            "id": "VcdOrg:::01234567-8910-1abc-d435-0abc1234d568"
                          },
                          {
                            "name": "Tenant2 vDC",
                            "id": "VcdOrgVdc:::01234567-8910-1abc-d435-0abc1234d568"
                          }
                        ],
                        "slaAssignment": "Direct",
                        "effectiveSlaSourceObjectId": "VcdVapp:::01234567-8910-1abc-d435-0abc1234d570",
                        "effectiveSlaSourceObjectName": "vApp04",
                        "vcdClusterName": "VMware vCloud Director",
                        "vcdClusterId": "01234567-8910-1abc-d435-0abc1234d567",
                        "configuredSlaDomainId": "01234567-8910-1abc-d435-0abc1234d568",
                        "effectiveSlaDomainName": "Bronze",
                        "isRelic": false,
                        "name": "vApp 04",
                        "id": "VcdVapp:::01234567-8910-1abc-d435-0abc1234d570"
                      }
                    ],
                    "total": 2
                  }'
                return ConvertFrom-Json $response
            }

            ( Get-RubrikVApp -SLAID '01234567-8910-1abc-d435-0abc1234d568' ).Length |
                Should -BeExactly 2
        }

        Assert-VerifiableMock
        Assert-MockCalled -CommandName Test-RubrikConnection -ModuleName 'Rubrik' -Times 4
        Assert-MockCalled -CommandName Get-RubrikSLA -ModuleName 'Rubrik' -Times 2
        Assert-MockCalled -CommandName Submit-Request -ModuleName 'Rubrik' -Times 4
    }

    Context -Name 'Parameter Validation' {
        It -Name 'Parameter Name cannot be $null' -Test {
            { Get-RubrikVApp -Name $null } |
                Should -Throw "Cannot validate argument on parameter 'Name'"
        }
        It -Name 'Parameter Name cannot be empty' -Test {
            { Get-RubrikVApp -Name '' } |
                Should -Throw "Cannot validate argument on parameter 'Name'"
        }
        It -Name 'Parameter ID cannot be $null' -Test {
            { Get-RubrikVApp -Id $null } |
                Should -Throw "Cannot validate argument on parameter 'ID'"
        }
        It -Name 'Parameter ID cannot be empty' -Test {
            { Get-RubrikVApp -Id '' } |
                Should -Throw "Cannot validate argument on parameter 'ID'"
        }
        It -Name 'Parameters Id and Name cannot be simultaneously used' -Test {
            { Get-RubrikVApp -Id VirtualMachine:::1226ff04-6100-454f-905b-5df817b6981a-vm-1025 -Name 'foo' } |
                Should -Throw "Parameter set cannot be resolved using the specified named parameters."
        }
        It -Name 'Parameter SLAAssignment must be valid' -Test {
            { Get-RubrikVApp -SLAAssignment 'foo' } |
                Should -Throw "Cannot validate argument on parameter 'SLAAssignment'"
        }
    }
}