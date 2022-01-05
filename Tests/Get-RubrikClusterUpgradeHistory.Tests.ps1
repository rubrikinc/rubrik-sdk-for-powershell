Remove-Module -Name 'Rubrik' -ErrorAction 'SilentlyContinue'
Import-Module -Name './Rubrik/Rubrik.psd1' -Force

foreach ( $privateFunctionFilePath in ( Get-ChildItem -Path './Rubrik/Private' | Where-Object extension -eq '.ps1').FullName  ) {
    . $privateFunctionFilePath
}

Describe -Name 'Public/Get-RubrikClusterUpgradeHistory' -Tag 'Public', 'Get-RubrikClusterUpgradeHistory' -Fixture {
    #region init
    $global:rubrikConnection = @{
        id      = 'test-id'
        userId  = 'test-userId'
        token   = 'test-token'
        server  = 'test-server'
        header  = @{ 'Authorization' = 'Bearer test-authorization' }
        time    = (Get-Date)
        api     = 'v1'
        version = '5.0.5'
    }
    #endregion

    Context -Name 'Results Filtering' {
        Mock -CommandName Test-RubrikConnection -Verifiable -ModuleName 'Rubrik' -MockWith {}
        Mock -CommandName Submit-Request -Verifiable -ModuleName 'Rubrik' -MockWith {
            @{ 
                'configChangeMetadata'                   = '{"old_state": "DEFAULT", "tarball_version": "5.3.0-18317"}'
                'modifiedDateTime'                       = '01/15/2021 19:42:06'
                'source'                                 = 'UPGRADE'
            },
            @{ 
                'configChangeMetadata'                   = '{"old_state": "DEFAULT", "tarball_version": "5.3.0-18317"}'
                'modifiedDateTime'                       = '01/15/2021 19:42:06'
                'source'                                 = 'UPGRADE'
            },
            @{ 
                'configChangeMetadata'                   = '{"old_state": "DEFAULT", "tarball_version": "5.4.0-18317"}'
                'modifiedDateTime'                       = '02/15/2021 19:42:06'
                'source'                                 = 'UPGRADE'
            },
            @{ 
                'configChangeMetadata'                   = '{"old_state": "DEFAULT", "tarball_version": "5.5.0-18317"}'
                'modifiedDateTime'                       = '03/15/2021 19:42:06'
                'source'                                 = 'UPGRADE'
            },
            @{ 
                'configChangeMetadata'                   = '{"old_state": "DEFAULT", "tarball_version": "5.5.0-18317"}'
                'modifiedDateTime'                       = '03/15/2021 19:42:06'
                'source'                                 = 'UPGRADE'
            },
            @{ 
                'configChangeMetadata'                   = '{"old_state": "DEFAULT", "tarball_version": "6.3.0-18317"}'
                'modifiedDateTime'                       = '04/15/2021 19:42:06'
                'source'                                 = 'UPGRADE'
            }
        }
        It -Name 'Should Return count of 4 Upgrades' -Test {
            ( Get-RubrikClusterUpgradeHistory).Count |
                Should -BeExactly 4
        }
        It -Name 'Source should be UPGRADE' -Test {
            (Get-RubrikClusterUpgradeHistory | Select-Object -First 1).source |
                Should -BeExactly 'UPGRADE'
        }
        It -Name 'DateTime field should be present' -Test {
            ( Get-RubrikClusterUpgradeHistory | Select-Object -First 1).DateTime |
                Should -Not -BeNullOrEmpty
        }
        It -Name 'Last upgraded version should be 6.3.0-18317' -Test {
            ( Get-RubrikClusterUpgradeHistory | Select-Object -Last 1).Version |
                Should -BeExactly '6.3.0-18317'
        }
        Assert-VerifiableMock
        Assert-MockCalled -CommandName Test-RubrikConnection -ModuleName 'Rubrik' -Exactly 4
        Assert-MockCalled -CommandName Submit-Request -ModuleName 'Rubrik' -Exactly 4
    }
}