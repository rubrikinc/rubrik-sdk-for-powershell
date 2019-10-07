Remove-Module -Name 'Rubrik' -ErrorAction 'SilentlyContinue'
Import-Module -Name './Rubrik/Rubrik.psd1' -Force

foreach ( $privateFunctionFilePath in ( Get-ChildItem -Path './Rubrik/Private' | Where-Object extension -eq '.ps1').FullName  ) {
    . $privateFunctionFilePath
}

Describe -Name 'Public/Get-RubrikVCD' -Tag 'Public', 'Get-RubrikVCD' -Fixture {
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
                    "hostname": "vcd.example.com",
                    "configuredSlaDomainName": "Inherit",
                    "primaryClusterId": "12345678-1234-abcd-8910-1234567890ab",
                    "name": "VMware vCloud Director",
                    "connectionStatus": {
                      "status": "Connected"
                    },
                    "id": "Vcd:::f96a2b1b-a06d-4f17-b6be-52141795532e",
                    "configuredSlaDomainId": "INHERIT",
                    "username": "administrator"
                  }
                ],
                "total": 1
              }'
            return ConvertFrom-Json $response
        }

        It -Name 'should return one result with no parameters' -Test {
            ( Get-RubrikVCD -Name 'VMware vCloud Director' | Measure-Object ).Count |
                Should -BeExactly 1
        }

        It -Name 'should filter on vCD Cluster Name' -Test {
            ( Get-RubrikVCD -Name 'VMware vCloud Director' ).Name |
                Should -BeExactly 'VMware vCloud Director'
        }

        It -Name 'should filter on vCD Cluster Hostname' -Test {
            ( Get-RubrikVCD -Hostname 'vcd.example.com' ).Hostname |
                Should -BeExactly 'vcd.example.com'
        }

        It -Name 'should filter on vCD Cluster Status' -Test {
            ( Get-RubrikVCD -Status 'Connected' ).Hostname |
                Should -BeExactly 'vcd.example.com'
        }

        It -Name 'should return one result with all parameters' -Test {
            ( Get-RubrikVCD -Name 'VMware vCloud Director' -Hostname 'vcd.example.com' -Status 'Connected' | Measure-Object ).Count |
                Should -BeExactly 1
        }

        Assert-VerifiableMock
        Assert-MockCalled -CommandName Test-RubrikConnection -ModuleName 'Rubrik' -Times 5
        Assert-MockCalled -CommandName Submit-Request -ModuleName 'Rubrik' -Times 5
    }

    Context -Name 'Parameter Validation' {
        It -Name 'Parameter Name cannot be $null' -Test {
            { Get-RubrikVCD -Name $null } |
                Should -Throw "Cannot validate argument on parameter 'Name'"
        }
        It -Name 'Parameter Name cannot be empty' -Test {
            { Get-RubrikVCD -Name '' } |
                Should -Throw "Cannot validate argument on parameter 'Name'"
        }
        It -Name 'Parameter Hostname cannot be $null' -Test {
            { Get-RubrikVCD -Hostname $null } |
                Should -Throw "Cannot validate argument on parameter 'Hostname'"
        }
        It -Name 'Parameter Hostname cannot be empty' -Test {
            { Get-RubrikVCD -Hostname '' } |
                Should -Throw "Cannot validate argument on parameter 'Hostname'"
        }
        It -Name 'Parameter Status must be valid' -Test {
            { Get-RubrikVCD -Status 'foo' } |
                Should -Throw "Cannot validate argument on parameter 'Status'"
        }
    }
}