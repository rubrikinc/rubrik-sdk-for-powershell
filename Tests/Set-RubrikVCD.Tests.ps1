Remove-Module -Name 'Rubrik' -ErrorAction 'SilentlyContinue'
Import-Module -Name './Rubrik/Rubrik.psd1' -Force

foreach ( $privateFunctionFilePath in ( Get-ChildItem -Path './Rubrik/Private' | Where-Object extension -eq '.ps1').FullName  ) {
    . $privateFunctionFilePath
}

Describe -Name 'Public/Set-RubrikVCD' -Tag 'Public', 'Set-RubrikVCD' -Fixture {
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

    Context -Name 'Parameter/SLA' {
        Mock -CommandName Test-RubrikConnection -Verifiable -ModuleName 'Rubrik' -MockWith {}
        Mock -CommandName Test-RubrikSLA -Verifiable -ModuleName 'Rubrik' -MockWith {
            @{ 'slaid' = '12345678-1234-abcd-8910-1234567890ab' }
        }
        Mock -CommandName Submit-Request -Verifiable -ModuleName 'Rubrik' -MockWith {
            $response = '{
                "hostname": "vcd.example.com",
                "configuredSlaDomainName": "Bronze",
                "primaryClusterId": "01234567-8910-1abc-d435-0abc1234d567",
                "name": "VMware vCloud Director",
                "connectionStatus": {
                  "status": "Connected"
                },
                "id": "Vcd:::01234567-8910-1abc-d435-0abc1234d567",
                "configuredSlaDomainId": "01234567-8910-1abc-d435-0abc1234d567",
                "username": "administrator"
            }'
            return ConvertFrom-Json $response
        }
        It -Name 'Should assign SLA' -Test {
            ( Set-RubrikVCD -id 'Vcd:::01234567-8910-1abc-d435-0abc1234d567' -SLA 'Bronze' ).configuredSlaDomainId |
                Should -BeExactly '01234567-8910-1abc-d435-0abc1234d567'
        }
        Assert-VerifiableMock
        Assert-MockCalled -CommandName Test-RubrikConnection -ModuleName 'Rubrik' -Times 1
        Assert-MockCalled -CommandName Test-RubrikSLA -ModuleName 'Rubrik' -Times 1        
        Assert-MockCalled -CommandName Submit-Request -ModuleName 'Rubrik' -Times 1
    }

    Context -Name 'Parameter/DoNotProtect' {
        Mock -CommandName Test-RubrikConnection -Verifiable -ModuleName 'Rubrik' -MockWith {}
        Mock -CommandName Test-RubrikSLA -Verifiable -ModuleName 'Rubrik' -MockWith {
            'UNPROTECTED'
        }
        Mock -CommandName Submit-Request -Verifiable -ModuleName 'Rubrik' -MockWith {
            $response = '{
                "hostname": "vcd.example.com",
                "configuredSlaDomainName": "Unprotected",
                "primaryClusterId": "01234567-8910-1abc-d435-0abc1234d567",
                "name": "VMware vCloud Director",
                "connectionStatus": {
                  "status": "Connected"
                },
                "id": "Vcd:::01234567-8910-1abc-d435-0abc1234d567",
                "configuredSlaDomainId": "UNPROTECTED",
                "username": "administrator"
            }'
            return ConvertFrom-Json $response
        }
        It -Name 'Should be Unprotected' -Test {
            ( Set-RubrikVCD -id 'VcdVapp:::01234567-8910-1abc-d435-0abc1234d567' -DoNotProtect).configuredSlaDomainId |
                Should -BeExactly 'UNPROTECTED'
        }
        Assert-VerifiableMock
        Assert-MockCalled -CommandName Test-RubrikConnection -ModuleName 'Rubrik' -Times 1
        Assert-MockCalled -CommandName Test-RubrikSLA -ModuleName 'Rubrik' -Times 1        
        Assert-MockCalled -CommandName Submit-Request -ModuleName 'Rubrik' -Times 1
    }

    Context -Name 'Parameter/Inherit' {
        Mock -CommandName Test-RubrikConnection -Verifiable -ModuleName 'Rubrik' -MockWith {}
        Mock -CommandName Test-RubrikSLA -Verifiable -ModuleName 'Rubrik' -MockWith {
            'UNPROTECTED'
        }
        Mock -CommandName Submit-Request -Verifiable -ModuleName 'Rubrik' -MockWith {
            $response = '{
                "hostname": "vcd.example.com",
                "configuredSlaDomainName": "Inherit",
                "primaryClusterId": "01234567-8910-1abc-d435-0abc1234d567",
                "name": "VMware vCloud Director",
                "connectionStatus": {
                  "status": "Connected"
                },
                "id": "Vcd:::01234567-8910-1abc-d435-0abc1234d567",
                "configuredSlaDomainId": "INHERIT",
                "username": "administrator"
            }'
            return ConvertFrom-Json $response
        }
        It -Name 'Should be Unprotected' -Test {
            ( Set-RubrikVCD -id 'VcdVapp:::01234567-8910-1abc-d435-0abc1234d567' -Inherit).configuredSlaDomainId |
                Should -BeExactly 'INHERIT'
        }
        Assert-VerifiableMock
        Assert-MockCalled -CommandName Test-RubrikConnection -ModuleName 'Rubrik' -Times 1
        Assert-MockCalled -CommandName Test-RubrikSLA -ModuleName 'Rubrik' -Times 1        
        Assert-MockCalled -CommandName Submit-Request -ModuleName 'Rubrik' -Times 1
    }

    Context -Name 'Parameter/Hostname' {
        Mock -CommandName Test-RubrikConnection -Verifiable -ModuleName 'Rubrik' -MockWith {}
        Mock -CommandName Submit-Request -Verifiable -ModuleName 'Rubrik' -MockWith {
            $response = '{
                "hostname": "newvcd.example.com",
                "configuredSlaDomainName": "Bronze",
                "primaryClusterId": "01234567-8910-1abc-d435-0abc1234d567",
                "name": "VMware vCloud Director",
                "connectionStatus": {
                  "status": "Connected"
                },
                "id": "Vcd:::01234567-8910-1abc-d435-0abc1234d567",
                "configuredSlaDomainId": "Vcd:::01234567-8910-1abc-d435-0abc1234d567",
                "username": "administrator"
            }'
            return ConvertFrom-Json $response
        }
        It -Name 'Hostname Should be Updated' -Test {
            ( Set-RubrikVCD -id 'VcdVapp:::01234567-8910-1abc-d435-0abc1234d567' -Hostname 'newvcd.example.com').hostname |
                Should -BeExactly 'newvcd.example.com'
        }
        Assert-VerifiableMock
        Assert-MockCalled -CommandName Test-RubrikConnection -ModuleName 'Rubrik' -Times 1     
        Assert-MockCalled -CommandName Submit-Request -ModuleName 'Rubrik' -Times 1
    }

    <#
    Context -Name 'Parameter/UpdateCreds' {
        Mock -CommandName Test-RubrikConnection -Verifiable -ModuleName 'Rubrik' -MockWith {}
        function Get-Credential {
            $password = ConvertTo-SecureString 'ANewPassword' -AsPlainText -Force
            $credential = New-Object System.Management.Automation.PSCredential ('newadmin', $password)
            $credential
        }
        Mock -CommandName Submit-Request -Verifiable -ModuleName 'Rubrik' -MockWith {
            $response = '{
                "hostname": "vcd.example.com",
                "configuredSlaDomainName": "Bronze",
                "primaryClusterId": "01234567-8910-1abc-d435-0abc1234d567",
                "name": "VMware vCloud Director",
                "connectionStatus": {
                  "status": "Connected"
                },
                "id": "Vcd:::01234567-8910-1abc-d435-0abc1234d567",
                "configuredSlaDomainId": "Vcd:::01234567-8910-1abc-d435-0abc1234d567",
                "username": "newadmin"
            }'
            return ConvertFrom-Json $response
        }
        It -Name 'Hostname Should be Updated' -Test {
            ( Set-RubrikVCD -id 'VcdVapp:::01234567-8910-1abc-d435-0abc1234d567' -UpdateCreds).username |
                Should -BeExactly 'newadmin'
        }
        Assert-VerifiableMock
        Assert-MockCalled -CommandName Test-RubrikConnection -ModuleName 'Rubrik' -Times 1
        Assert-MockCalled -CommandName Get-Credential -ModuleName 'Rubrik' -Times 1
        Assert-MockCalled -CommandName Submit-Request -ModuleName 'Rubrik' -Times 1
    }
    #>

    Context -Name 'Parameter Validation' {
        It -Name 'Parameter ID cannot be $null' -Test {
            { Set-RubrikVCD -Id $null } |
                Should -Throw "Cannot validate argument on parameter 'ID'"
        }
        It -Name 'Parameter ID cannot be empty' -Test {
            { Set-RubrikVCD -Id '' } |
                Should -Throw "Cannot validate argument on parameter 'ID'"
        }
        It -Name 'Parameters SLA and DoNotProtect cannot be simultaneously used' -Test {
            { Set-RubrikVCD -Id VcdVapp:::01234567-8910-1abc-d435-0abc1234d567 -SLA Gold -DoNotProtect} |
                Should -Throw "Parameter set cannot be resolved using the specified named parameters."
        }
        It -Name 'Parameters SLA and Inherit cannot be simultaneously used' -Test {
            { Set-RubrikVCD -Id VcdVapp:::01234567-8910-1abc-d435-0abc1234d567 -SLA Gold -Inherit} |
                Should -Throw "Parameter set cannot be resolved using the specified named parameters."
        }
        It -Name 'Parameters DoNotProtect and Inherit cannot be simultaneously used' -Test {
            { Set-RubrikVCD -Id VcdVapp:::01234567-8910-1abc-d435-0abc1234d567 -DoNotProtect -Inherit} |
                Should -Throw "Parameter set cannot be resolved using the specified named parameters."
        }
    }
}