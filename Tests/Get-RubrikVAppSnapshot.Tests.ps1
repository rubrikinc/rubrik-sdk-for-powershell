Remove-Module -Name 'Rubrik' -ErrorAction 'SilentlyContinue'
Import-Module -Name './Rubrik/Rubrik.psd1' -Force

foreach ( $privateFunctionFilePath in ( Get-ChildItem -Path './Rubrik/Private' | Where-Object extension -eq '.ps1').FullName  ) {
    . $privateFunctionFilePath
}

Describe -Name 'Public/Get-RubrikVAppSnapshot' -Tag 'Public', 'Get-RubrikVAppSnapshot' -Fixture {
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
            $response = '{"data": {
                "date": "2019-07-19T16:38:22.826Z",
                "indexState": 1,
                "slaName": "Silver",
                "vappName": "vApp01",
                "slaId": "01234567-8910-1abc-d435-0abc1234d567",
                "replicationLocationIds": [],
                "archivalLocationIds": [
                  "01234567-8910-1abc-d435-0abc1234d567"
                ],
                "networks": [
                  {
                    "name": "Production",
                    "isDeployed": true
                  },
                  {
                    "name": "Production",
                    "parentNetworkId": "01234567-8910-1abc-d435-0abc1234d567",
                    "isDeployed": true
                  }
                ],
                "isOnDemandSnapshot": true,
                "cloudState": 2,
                "excludedVcdVmMoids": [],
                "vmSnapshots": [
                  {
                    "vcenterVmId": "01234567-8910-1abc-d435-0abc1234d567-vm-12345",
                    "indexState": 2,
                    "vmName": "vm01",
                    "networkConnections": [
                      {
                        "nicIndex": 0,
                        "macAddress": "00:11:22:33:44:55",
                        "addressingMode": "DHCP",
                        "ipAddress": "192.168.1.101",
                        "vappNetworkName": "Production",
                        "isConnected": true
                      }
                    ],
                    "vmSnapshotId": "01234567-8910-1abc-d435-0abc1234d567",
                    "vcdVmMoid": "vm-01234567-8910-1abc-d435-0abc1234d567"
                  }
                ],
                "id": "01234567-8910-1abc-d435-0abc1234d567"
              }}'
            return ConvertFrom-Json $response
        }

        It -Name 'Expected results returned' -Test {
            ( Get-RubrikVAppSnapshot -ID '4a7c0e3a-e48b-4f3b-8a51-efc6bd769863' ).vappName |
                Should -BeExactly "vApp01"
        }

        Assert-VerifiableMock
        Assert-MockCalled -CommandName Test-RubrikConnection -ModuleName 'Rubrik' -Times 1
        Assert-MockCalled -CommandName Submit-Request -ModuleName 'Rubrik' -Times 1
    }

    Context -Name 'Parameter Validation' {
        It -Name 'Parameter ID cannot be $null' -Test {
            { Get-RubrikVAppSnapshot -Id $null } |
                Should -Throw "Cannot validate argument on parameter 'ID'"
        }
        It -Name 'Parameter ID cannot be empty' -Test {
            { Get-RubrikVAppSnapshot -Id '' } |
                Should -Throw "Cannot validate argument on parameter 'ID'"
        }
    }
}