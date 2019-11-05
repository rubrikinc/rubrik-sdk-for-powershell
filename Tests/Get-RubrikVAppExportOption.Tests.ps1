Remove-Module -Name 'Rubrik' -ErrorAction 'SilentlyContinue'
Import-Module -Name './Rubrik/Rubrik.psd1' -Force

foreach ( $privateFunctionFilePath in ( Get-ChildItem -Path './Rubrik/Private' | Where-Object extension -eq '.ps1').FullName  ) {
    . $privateFunctionFilePath
}

Describe -Name 'Public/Get-RubrikVAppExportOption' -Tag 'Public', 'Get-RubrikVAppExportOption' -Fixture {
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

    Context -Name 'Request Succeeds' {
        Mock -CommandName Test-RubrikConnection -Verifiable -ModuleName 'Rubrik' -MockWith {}
        Mock -CommandName Submit-Request -Verifiable -ModuleName 'Rubrik' -MockWith {
            $exportoptsjson = '{
                "allChildVmsWithDefaultNetworkConnections": [
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
                "restorableNetworks": [],
                "targetVappNetworks": [
                  {
                    "name": "network01",
                    "isDeployed": true
                  },
                  {
                    "name": "network02",
                    "parentNetworkId": "01234567-8910-1abc-d435-0abc1234d567",
                    "isDeployed": true
                  }
                ],
                "availableStoragePolicies": [
                  {
                    "name": "Default Storage Policy",
                    "id": "01234567-8910-1abc-d435-0abc1234d567"
                  }
                ]
              }'
            return ConvertFrom-Json -InputObject $exportoptsjson
        }

        It -Name 'Expected results returned' -Test {
            $result = Get-RubrikVAppExportOption -id '01234567-8910-1abc-d435-0abc1234d567' -ExportMode 'ExportToNewVapp'
            $result.allChildVmsWithDefaultNetworkConnections[0].name | Should -BeExactly 'vApp01'
            $result.targetVappNetworks[0].name | Should -BeExactly 'network01'
        }
        
        Assert-VerifiableMock
        Assert-MockCalled -CommandName Test-RubrikConnection -ModuleName 'Rubrik' -Times 1
        Assert-MockCalled -CommandName Submit-Request -ModuleName 'Rubrik' -Times 1
    }
    Context -Name 'Parameter Validation' {
        It -Name 'Parameter ID cannot be null' -Test {
           { Get-RubrikVAppExportOption -id $null } |
                Should -Throw "Cannot validate argument on parameter 'id'. The argument is null or empty. Provide an argument that is not null or empty, and then try the command again."
        } 
        It -Name 'Parameter ID cannot be empty' -Test {
            { Get-RubrikVAppExportOption -id '' } |
                Should -Throw "Cannot validate argument on parameter 'id'. The argument is null or empty. Provide an argument that is not null or empty, and then try the command again."
        }
    }
}