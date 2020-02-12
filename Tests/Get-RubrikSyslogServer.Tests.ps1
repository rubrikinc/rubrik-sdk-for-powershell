Remove-Module -Name 'Rubrik' -ErrorAction 'SilentlyContinue'
Import-Module -Name './Rubrik/Rubrik.psd1' -Force

foreach ( $privateFunctionFilePath in ( Get-ChildItem -Path './Rubrik/Private' | Where-Object extension -eq '.ps1').FullName  ) {
    . $privateFunctionFilePath
}

Describe -Name 'Public/Get-RubrikSyslogServer' -Tag 'Public', 'Get-RubrikSyslogServer' -Fixture {
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
                'hasmore'   = 'false'
                'total'     = '1'
                'data'      =
                @{ 
                    'hostname'  = 'syslog1.domain.local'
                    'protocol'  = 'UDP'
                    'port'      = '514'
                    'id'        = '1'
                },
                @{
                    'hostname'  = 'syslog2.domain.local'
                    'protocol'  = 'UDP'
                    'port'      = '514'
                    'id'        = '1'                   
                }
            }

        }
        It -Name 'No parameters returns all results' -Test {
            @( Get-RubrikSyslogServer).Count |
                Should -BeExactly 2
        }
        It -Name 'Name filter functionality' -Test {
            @(Get-RubrikSyslogServer -Name 'syslog2.domain.local').hostname |
                Should -BeExactly 'syslog2.domain.local'
        }
        It -Name 'Non existant name should return nothing' -Test {
            @(Get-RubrikSyslogServer -Name 'non existant').hostname |
                Should -BeExactly $null
        }
        Assert-VerifiableMock
        Assert-MockCalled -CommandName Test-RubrikConnection -ModuleName 'Rubrik' -Exactly 3
        Assert-MockCalled -CommandName Submit-Request -ModuleName 'Rubrik' -Exactly 3
    }
}