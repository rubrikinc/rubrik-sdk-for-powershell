Remove-Module -Name 'Rubrik' -ErrorAction 'SilentlyContinue'
Import-Module -Name './Rubrik/Rubrik.psd1' -Force

foreach ( $privateFunctionFilePath in ( Get-ChildItem -Path './Rubrik/Private' | Where-Object extension -eq '.ps1').FullName  ) {
    . $privateFunctionFilePath
}

Describe -Name 'Public/Set-RubrikOrgAuthorization' -Tag 'Public', 'Set-RubrikOrgAuthorization' -Fixture {
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

    Context -Name 'Results Validation' {
        Mock -CommandName Test-RubrikConnection -Verifiable -ModuleName 'Rubrik' -MockWith {}
        Mock -CommandName Get-RubrikOrganization -Verifiable -ModuleName 'Rubrik' -MockWith {
            $json = '{"data": {
                "name": "SampleOrg",
                "isGlobal": false,
                "envoyStatus": false,
                "id": "Organization:::01234567-8910-1abc-d435-0abc1234d567"
              }}'
            return ConvertFrom-Json $json
        } 
        Mock -CommandName Submit-Request -Verifiable -ModuleName 'Rubrik' -MockWith {
            $json = '{
                "hasMore": false,
                "data": [
                  {
                    "principal": "Organization:::01234567-8910-1abc-d435-0abc1234d567",
                    "privileges": {
                      "manageCluster": [],
                      "useSla": [
                          "SlaDomain:::12345678-1234-abcd-8910-1234567890ab"
                      ],
                      "manageResource": [
                        "User:::01234567-8910-1abc-d435-0abc1234d567",
                        "VirtualMachine:::aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee-vm-12345"
                      ],
                      "manageSla": []
                    },
                    "organizationId": "Organization:::01234567-8910-1abc-d435-0abc1234d567"
                  }
                ],
                "total": 1
              }'
            return ConvertFrom-Json $json
        }
        It -Name 'Should Return Correct Organization Authorization info' -Test {
            $return = Set-RubrikOrgAuthorization -ID 'Organization:::01234567-8910-1abc-d435-0abc1234d567' -ManageResource 'VirtualMachine:::aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee-vm-12345'
            $return.organizationId | Should -BeExactly 'Organization:::01234567-8910-1abc-d435-0abc1234d567'
            $return.principal | Should -BeExactly 'Organization:::01234567-8910-1abc-d435-0abc1234d567'
            $return.privileges.useSla -contains "SlaDomain:::12345678-1234-abcd-8910-1234567890ab" | Should -BeExactly $true
            $return.privileges.manageResource -contains "VirtualMachine:::aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee-vm-12345" | Should -BeExactly $true
        }
        
        Assert-VerifiableMock
        Assert-MockCalled -CommandName Get-RubrikOrganization -ModuleName 'Rubrik' -Exactly 1
        Assert-MockCalled -CommandName Test-RubrikConnection -ModuleName 'Rubrik' -Exactly 1
        Assert-MockCalled -CommandName Submit-Request -ModuleName 'Rubrik' -Exactly 1
    }

    Context -Name 'Global Org' {
        Mock -CommandName Test-RubrikConnection -Verifiable -ModuleName 'Rubrik' -MockWith {}
        Mock -CommandName Submit-Request -Verifiable -ModuleName 'Rubrik' -MockWith {
            $json = '{"data": {
                "name": "Global",
                "isGlobal": true,
                "envoyStatus": false,
                "id": "Organization:::01234567-8910-1abc-d435-0abc1234d567"
              }}'
            return ConvertFrom-Json $json
        }
        It -Name 'Should throw an error on Global Org' -Test {
            { Set-RubrikOrgAuthorization -ID 'Organization:::01234567-8910-1abc-d435-0abc1234d567' -ManageResource 'VirtualMachine:::aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee-vm-12345'} |
                Should -Throw "Operation not supported on Global Organization"
        }
        
        Assert-VerifiableMock
        Assert-MockCalled -CommandName Submit-Request -ModuleName 'Rubrik' -Exactly 1
        Assert-MockCalled -CommandName Test-RubrikConnection -ModuleName 'Rubrik' -Exactly 2
    }

    Context -Name 'Parameter Validation' {
        Mock -CommandName Test-RubrikConnection -Verifiable -ModuleName 'Rubrik' -MockWith {}
        Mock -CommandName Submit-Request -Verifiable -ModuleName 'Rubrik' -MockWith {}

        It -Name 'Parameter Missing' -Test {
            { Set-RubrikOrgAuthorization  -ID 'Organization:::01234567-8910-1abc-d435-0abc1234d567' } |
                Should -Throw "At least one of the parameters -UseSLA, -ManageResource, or -ManageSLA must be supplied"
        }   

        Assert-VerifiableMock
        Assert-MockCalled -CommandName Submit-Request -ModuleName 'Rubrik' -Exactly 1
        Assert-MockCalled -CommandName Test-RubrikConnection -ModuleName 'Rubrik' -Exactly 2
    }
}