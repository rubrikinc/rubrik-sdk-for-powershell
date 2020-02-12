Remove-Module -Name 'Rubrik' -ErrorAction 'SilentlyContinue'
Import-Module -Name './Rubrik/Rubrik.psd1' -Force

foreach ( $privateFunctionFilePath in ( Get-ChildItem -Path './Rubrik/Private' | Where-Object extension -eq '.ps1').FullName  ) {
    . $privateFunctionFilePath
}

Describe -Name 'Public/Get-RubrikNode' -Tag 'Public', 'Get-RubrikNode' -Fixture {
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

    Context -Name 'Results Filtering' {
        Mock -CommandName Test-RubrikConnection -Verifiable -ModuleName 'Rubrik' -MockWith { }
        Mock -CommandName Submit-Request -Verifiable -ModuleName 'Rubrik' -MockWith {
            @{ 
                'brikId'    = 'ABC123'
                'id'        = 'RVM111'
                'ipAddress' = '10.0.0.101'
                'status'    = 'OK'
            },
            @{ 
                'brikId'    = 'ABC123'
                'id'        = 'RVM222'
                'ipAddress' = '10.0.0.102'
                'status'    = 'OK'
            },
            @{ 
                'brikId'    = 'ABC123'
                'id'        = 'RVM333'
                'ipAddress' = '10.0.0.103'
                'status'    = 'OK'
            },
            @{ 
                'brikId'    = 'ABC123'
                'id'        = 'RVM444'
                'ipAddress' = '10.0.0.104'
                'status'    = 'OK'
            }
        }
        It -Name 'Should Return count of 4' -Test {
            (Get-RubrikNode).Count |
                Should -BeExactly 4
        }
        It -Name 'Should not run with Name parameter' -Test {
            { Get-RubrikNode -Name doesnotexist -ErrorAction Stop } |
                Should -Throw
        }

        
        Assert-VerifiableMock
        Assert-MockCalled -CommandName Test-RubrikConnection -ModuleName 'Rubrik' -Exactly 1
        Assert-MockCalled -CommandName Submit-Request -ModuleName 'Rubrik' -Exactly 1
    }
}
