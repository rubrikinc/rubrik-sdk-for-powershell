Remove-Module -Name 'Rubrik' -ErrorAction 'SilentlyContinue'
Import-Module -Name './Rubrik/Rubrik.psd1' -Force

foreach ( $privateFunctionFilePath in ( Get-ChildItem -Path './Rubrik/Private' | Where-Object extension -eq '.ps1').FullName  ) {
    . $privateFunctionFilePath
}

Describe -Name 'Public/Protect-RubrikDatabase' -Tag 'Public', 'Protect-RubrikDatabase' -Fixture {
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
        Mock -CommandName Test-RubrikSLA -Verifiable -ModuleName 'Rubrik' -MockWith {
            @{ 'slaid' = '12345678-1234-abcd-8910-1234567890ab' }
        }
        Mock -CommandName Submit-Request -Verifiable -ModuleName 'Rubrik' -MockWith {
            $response = '{
                "effectiveSlaDomainId": "12345678-1234-abcd-8910-1234567890ab",
                "primaryClusterId": "12345678-1234-abcd-8910-1234567890ab",
                "instanceName": "MSSQLSERVER",
                "unprotectableReasons": [],
                "configuredSlaDomainId": "12345678-1234-abcd-8910-1234567890ab",
                "isLogShippingSecondary": false,
                "effectiveSlaDomainName": "Gold",
                "instanceId": "MssqlInstance:::12345678-1234-abcd-8910-1234567890ab",
                "recoveryModel": "FULL",
                "id": "MssqlDatabase:::12345678-1234-abcd-8910-1234567890ab",
                "state": "ONLINE",
                "configuredSlaDomainName": "Gold",
                "replicas": [],
                "slaAssignment": "Direct",
                "rootProperties": {
                    "rootType": "Host",
                    "rootId": "Host:::12345678-1234-abcd-8910-1234567890ab",
                    "rootName": "sqlserver.example.us"
                },
                "logBackupRetentionHours": 24,
                "isRelic": false,
                "name": "ExampleDB1",
                "logBackupFrequencyInSeconds": 300
            }'
            return ConvertFrom-Json $response
        }
        It -Name 'Verify results match expected values' -Test {
            $results = Protect-RubrikDatabase -ID 'MssqlDatabase:::12345678-1234-abcd-8910-1234567890ab' -SLA 'Gold' -Confirm:$false
            $results.Name | Should -BeExactly 'ExampleDB1'
            $results.effectiveSlaDomainName | Should -BeExactly 'Gold'
            $results.effectiveSlaDomainId | Should -BeExactly '12345678-1234-abcd-8910-1234567890ab'
            $results.configuredSlaDomainName | Should -BeExactly 'Gold'
            $results.configuredSlaDomainId | Should -BeExactly '12345678-1234-abcd-8910-1234567890ab'
            $results.instanceName | Should -BeExactly 'MSSQLSERVER'
        }
        Assert-VerifiableMock
        Assert-MockCalled -CommandName Test-RubrikConnection -ModuleName 'Rubrik' -Times 1
        Assert-MockCalled -CommandName Test-RubrikSLA -ModuleName 'Rubrik' -Times 1
        Assert-MockCalled -CommandName Submit-Request -ModuleName 'Rubrik' -Times 1
    }

    Context -Name 'Parameter Validation' {
        It -Name 'Parameter ID cannot be $null' -Test {
            { Protect-RubrikDatabase -Id $null } |
                Should -Throw "Cannot validate argument on parameter 'ID'"
        }
        It -Name 'Parameter ID cannot be empty' -Test {
            { Protect-RubrikDatabase -Id '' } |
                Should -Throw "Cannot validate argument on parameter 'ID'"
        }
        It -Name 'Parameters SLA and DoNotProtect cannot be simultaneously used' -Test {
            { Protect-RubrikDatabase -Id 'MssqlDatabase:::12345678-1234-abcd-8910-1234567890ab'-SLA Gold -DoNotProtect} |
                Should -Throw "Parameter set cannot be resolved using the specified named parameters."
        }
        It -Name 'Parameters SLA and Inherit cannot be simultaneously used' -Test {
            { Protect-RubrikDatabase -Id 'MssqlDatabase:::12345678-1234-abcd-8910-1234567890ab' -SLA Gold -Inherit} |
                Should -Throw "Parameter set cannot be resolved using the specified named parameters."
        }
        It -Name 'Parameters DoNotProtect and Inherit cannot be simultaneously used' -Test {
            { Protect-RubrikDatabase -Id 'MssqlDatabase:::12345678-1234-abcd-8910-1234567890ab' -DoNotProtect -Inherit} |
                Should -Throw "Parameter set cannot be resolved using the specified named parameters."
        }
    }
}