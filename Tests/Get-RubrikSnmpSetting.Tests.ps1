Remove-Module -Name 'Rubrik' -ErrorAction 'SilentlyContinue'
Import-Module -Name './Rubrik/Rubrik.psd1' -Force

foreach ( $privateFunctionFilePath in ( Get-ChildItem -Path './Rubrik/Private' | Where-Object extension -eq '.ps1').FullName  ) {
    . $privateFunctionFilePath
}

Describe -Name 'Public/Get-RubrikSnmpSetting' -Tag 'Public', 'Get-RubrikSnmpSetting' -Fixture {
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

    Context -Name 'Returned Results' {
        Mock -CommandName Test-RubrikConnection -Verifiable -ModuleName 'Rubrik' -MockWith { }
        Mock -CommandName Submit-Request -Verifiable -ModuleName 'Rubrik' -MockWith {
            @{ 
                'communityString'     = 'SNMPString' 
                'snmpAgentPort'       = 'https'
                'isEnabled'           = 'true'
                'trapRecieverConfigs' = ''
            }
        }
        It -Name 'No parameters returns all results' -Test {
            @( Get-RubrikSnmpSetting | Measure-Object).Count |
                Should -BeExactly 1
        }
        It -Name 'Port is https' -Test {
            @( Get-RubrikSnmpSetting).snmpAgentPort |
                Should -BeExactly 'https'
        }

        Assert-VerifiableMock
        Assert-MockCalled -CommandName Test-RubrikConnection -ModuleName 'Rubrik' -Exactly 2
        Assert-MockCalled -CommandName Submit-Request -ModuleName 'Rubrik' -Exactly 2
    }
}