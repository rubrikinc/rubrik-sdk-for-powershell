Remove-Module -Name 'Rubrik' -ErrorAction 'SilentlyContinue'
Import-Module -Name './Rubrik/Rubrik.psd1' -Force

foreach ( $privateFunctionFilePath in ( Get-ChildItem -Path './Rubrik/Private' | Where-Object extension -eq '.ps1').FullName  ) {
    . $privateFunctionFilePath
}

Describe -Name 'Public/Get-RubrikOrgAuthorization' -Tag 'Public', 'Get-RubrikOrgAuthorization' -Fixture {
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
            $return = Get-RubrikOrgAuthorization -ID 'Organization:::01234567-8910-1abc-d435-0abc1234d567'
            $return.organizationId | Should -BeExactly 'Organization:::01234567-8910-1abc-d435-0abc1234d567'
            $return.principal | Should -BeExactly 'Organization:::01234567-8910-1abc-d435-0abc1234d567'
            $return.privileges.useSla[0] | Should -BeExactly "SlaDomain:::12345678-1234-abcd-8910-1234567890ab"
            $return.privileges.manageResource[0] | Should -BeExactly "User:::01234567-8910-1abc-d435-0abc1234d567"
        }
        
        Assert-VerifiableMock
        Assert-MockCalled -CommandName Test-RubrikConnection -ModuleName 'Rubrik' -Exactly 2
        Assert-MockCalled -CommandName Submit-Request -ModuleName 'Rubrik' -Exactly 2
    }
}