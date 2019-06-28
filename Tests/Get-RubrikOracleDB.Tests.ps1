Remove-Module -Name 'Rubrik' -ErrorAction 'SilentlyContinue'
Import-Module -Name './Rubrik/Rubrik.psd1' -Force

foreach ( $privateFunctionFilePath in ( Get-ChildItem -Path './Rubrik/Private' | Where-Object extension -eq '.ps1').FullName  ) {
    . $privateFunctionFilePath
}

Describe -Name 'Public/Get-RubrikOracleDB' -Tag 'Public', 'Get-RubrikOracleDB' -Fixture {
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
        Mock -CommandName Get-RubrikSLA -Verifiable -ModuleName 'Rubrik' -MockWith {
            @{ 'id' = 'test-sla_id' }
        }
        Mock -CommandName Submit-Request -Verifiable -ModuleName 'Rubrik' -MockWith {
            @{ 
                'name'                   = 'test-oracledb1'
                'effectiveSlaDomainName' = 'test-valid_sla_name'
            },
            @{ # The server-side filter should not return this record, but this record will validate the response filter logic
                'name'                   = 'test-oracledb2'
                'effectiveSlaDomainName' = 'test-invalid_sla_name'
            }
        }
        It -Name 'should overwrite $SLAID' -Test {
            ( Get-RubrikOracleDB -SLA 'test-valid_sla_name' ).Name |
                Should -BeExactly 'test-oracledb1'
        }
        Assert-VerifiableMock
        Assert-MockCalled -CommandName Test-RubrikConnection -ModuleName 'Rubrik' -Times 1
        Assert-MockCalled -CommandName Get-RubrikSLA -ModuleName 'Rubrik' -Times 1
        Assert-MockCalled -CommandName Submit-Request -ModuleName 'Rubrik' -Times 1
    }

    Context -Name 'Parameter/SLAID' {
        Mock -CommandName Test-RubrikConnection -Verifiable -ModuleName 'Rubrik' -MockWith {}
        Mock -CommandName Submit-Request -Verifiable -ModuleName 'Rubrik' -MockWith {
            @{ 
                'name'                   = 'test-oracledb1'
                'effectiveSlaDomainName' = 'test-valid_sla_name'
            }
        }
        It -Name 'SLAID Query should return OracleDB1 DB' -Test {
            ( Get-RubrikOracleDB -SLAID 'test-valid_sla_id' ).Name |
                Should -BeExactly 'test-oracledb1'
        }
        It -Name 'SLAID Query should return OracleDB1 SLA' -Test {
            ( Get-RubrikOracleDB -SLAID 'test-valid_sla_id' ).effectiveSlaDomainName |
                Should -BeExactly 'test-valid_sla_name'
        }
        Assert-VerifiableMock
        Assert-MockCalled -CommandName Test-RubrikConnection -ModuleName 'Rubrik' -Times 1
        Assert-MockCalled -CommandName Submit-Request -ModuleName 'Rubrik' -Times 1
    }
}