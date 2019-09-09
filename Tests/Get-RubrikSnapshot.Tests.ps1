Remove-Module -Name 'Rubrik' -ErrorAction 'SilentlyContinue'
Import-Module -Name './Rubrik/Rubrik.psd1' -Force

foreach ( $privateFunctionFilePath in ( Get-ChildItem -Path './Rubrik/Private' | Where-Object extension -eq '.ps1').FullName  ) {
    . $privateFunctionFilePath
}

Describe -Name 'Public/Get-RubrikSnapshot' -Tag 'Public', 'Get-RubrikSnapshot' -Fixture {
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
                    "date": "2019-08-01T01:00:00.000Z",
                    "indexState": 1,
                    "slaName": "Gold",
                    "vmName": "Example-VM",
                    "slaId": "12345678-1234-abcd-8910-1234567890ab",
                    "replicationLocationIds": [],
                    "archivalLocationIds": [],
                    "isOnDemandSnapshot": false,
                    "cloudState": 2,
                    "id": "4d70bd92-71b3-44cd-8bbb-0a89c0247bfd",
                    "consistencyLevel": "CRASH_CONSISTENT"
                  },
                  {
                    "date": "2019-08-02T01:00:00.000Z",
                    "indexState": 1,
                    "slaName": "Gold",
                    "vmName": "Example-VM",
                    "slaId": "12345678-1234-abcd-8910-1234567890ab",
                    "replicationLocationIds": [],
                    "archivalLocationIds": [],
                    "isOnDemandSnapshot": true,
                    "cloudState": 0,
                    "id": "2ec41b1d-6411-4cb4-b4a8-9ea621c915be",
                    "consistencyLevel": "CRASH_CONSISTENT"
                  },
                  {
                    "date": "2019-08-03T01:00:00.000Z",
                    "indexState": 1,
                    "slaName": "Gold",
                    "vmName": "Example-VM",
                    "slaId": "12345678-1234-abcd-8910-1234567890ab",
                    "replicationLocationIds": [],
                    "archivalLocationIds": [],
                    "isOnDemandSnapshot": false,
                    "cloudState": 0,
                    "id": "ca214725-6dcd-49b4-88ae-45780b16879a",
                    "consistencyLevel": "CRASH_CONSISTENT"
                  },
                  {
                    "date": "2019-08-04T01:00:00.000Z",
                    "indexState": 1,
                    "slaName": "Gold",
                    "vmName": "Example-VM",
                    "slaId": "12345678-1234-abcd-8910-1234567890ab",
                    "replicationLocationIds": [],
                    "archivalLocationIds": [],
                    "isOnDemandSnapshot": false,
                    "cloudState": 0,
                    "id": "87a5acac-caaa-48f9-b880-be0c759e05c2",
                    "consistencyLevel": "CRASH_CONSISTENT"
                  },
                  {
                    "date": "2019-08-05T01:00:00.000Z",
                    "indexState": 1,
                    "slaName": "Gold",
                    "vmName": "Example-VM",
                    "slaId": "12345678-1234-abcd-8910-1234567890ab",
                    "replicationLocationIds": [],
                    "archivalLocationIds": [],
                    "isOnDemandSnapshot": false,
                    "cloudState": 0,
                    "id": "b42ed6ba-760e-425f-a35d-c7dc5636b55d",
                    "consistencyLevel": "CRASH_CONSISTENT"
                  }
                ],
                "total": 5
              }'
            return ConvertFrom-Json $response
        }
        It -Name 'Get all snapshots' -Test {
            ( Get-RubrikSnapshot -id 'VirtualMachine:::aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee-vm-12345' ).Count |
                Should -BeExactly 5
        }
        It -Name 'Get latest snapshot' -Test {
          ( Get-RubrikSnapshot -id 'VirtualMachine:::aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee-vm-12345' -Latest ).id |
              Should -BeExactly "b42ed6ba-760e-425f-a35d-c7dc5636b55d"
        }
        It -Name 'Get specific snapshot' -Test {
          ( Get-RubrikSnapshot -id 'VirtualMachine:::aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee-vm-12345' -Date (Get-Date -Day 3 -Month 8 -Year 2019).Date ).id |
              Should -BeExactly "ca214725-6dcd-49b4-88ae-45780b16879a"
        }
        It -Name 'Get on demand snapshots' -Test {
          ( Get-RubrikSnapshot -id 'VirtualMachine:::aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee-vm-12345' -OnDemandSnapshot).id |
              Should -BeExactly "2ec41b1d-6411-4cb4-b4a8-9ea621c915be"
        }
        It -Name 'Get archived snapshots' -Test {
          ( Get-RubrikSnapshot -id 'VirtualMachine:::aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee-vm-12345' -CloudState 2).id |
              Should -BeExactly "4d70bd92-71b3-44cd-8bbb-0a89c0247bfd"
        }
        It -Name 'Test -ExactMatch' -Test {
          ( Get-RubrikSnapshot -id 'VirtualMachine:::aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee-vm-12345' -Date (Get-Date -Day 30 -Month 7 -Year 2019).Date -ExactMatch ) |
              Should -BeExactly $null
        }
        It -Name 'Test -Range' -Test {
          ( Get-RubrikSnapshot -id 'VirtualMachine:::aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee-vm-12345' -Date (Get-Date -Day 8 -Month 8 -Year 2019).Date -Range 4).id |
              Should -BeExactly "b42ed6ba-760e-425f-a35d-c7dc5636b55d"
        }
        It -Name 'Test -Range and -ExactMatch' -Test {
          ( Get-RubrikSnapshot -id 'VirtualMachine:::aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee-vm-12345' -Date (Get-Date -Day 8 -Month 8 -Year 2019).Date -Range 4 -ExactMatch ).id |
              Should -BeExactly "b42ed6ba-760e-425f-a35d-c7dc5636b55d"
        }
        It -Name 'Test -Range with out of range date' -Test {
          ( Get-RubrikSnapshot -id 'VirtualMachine:::aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee-vm-12345' -Date (Get-Date -Day 10 -Month 8 -Year 2019).Date -Range 3 ).Count |
              Should -BeExactly 5
        }
        Assert-VerifiableMock
        Assert-MockCalled -CommandName Test-RubrikConnection -ModuleName 'Rubrik' -Times 1
        Assert-MockCalled -CommandName Submit-Request -ModuleName 'Rubrik' -Times 1
    }

    Context -Name 'Parameter Validation' {
        It -Name 'Parameter ID cannot be $null' -Test {
            { Get-RubrikSnapshot -Id $null } |
                Should -Throw "Cannot validate argument on parameter 'ID'"
        }
        It -Name 'Parameter ID cannot be empty' -Test {
            { Get-RubrikSnapshot -Id '' } |
                Should -Throw "Cannot validate argument on parameter 'ID'"
        }
        It -Name 'Parameter Date cannot be $null' -Test {
          { Get-RubrikSnapshot -Date $null } |
              Should -Throw "Cannot process argument transformation on parameter 'Date'"
      }
      It -Name 'Parameter Date cannot be empty' -Test {
          { Get-RubrikSnapshot -Date '' } |
              Should -Throw "Cannot process argument transformation on parameter 'Date'"
      }
        It -Name 'Parameters Date and Latest cannot be simultaneously used' -Test {
            { Get-RubrikSnapshot -Id VirtualMachine:::aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee-vm-12345 -Date (Get-Date) -Latest } |
                Should -Throw "Parameter set cannot be resolved using the specified named parameters."
        }
    }
}