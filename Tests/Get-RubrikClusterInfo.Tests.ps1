Remove-Module -Name 'Rubrik' -ErrorAction 'SilentlyContinue'
Import-Module -Name './Rubrik/Rubrik.psd1' -Force

foreach ( $privateFunctionFilePath in ( Get-ChildItem -Path './Rubrik/Private' | Where-Object extension -eq '.ps1').FullName  ) {
    . $privateFunctionFilePath
}

Describe -Name 'Public/Get-RubrikClusterInfo' -Tag 'Public', 'Get-RubrikClusterInfo' -Fixture {
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
        Mock -CommandName Test-RubrikConnection -Verifiable -ModuleName 'Rubrik' -MockWith {}
        Mock -CommandName Submit-Request -Verifiable -ModuleName 'Rubrik' -MockWith {
            @{ 
                'name'                 = 'ClusterName'
                'cpuCoresC'            = '32'
                'id'                   = '111111-2222-3333-4444-555555555555'
                'isRegistered'         = 'False'
                'softwareVersion'      = '5.0.2'   
            }
        }
        It -Name 'No parameters returns all results' -Test {
            @( Get-RubrikClusterInfo).Count |
                Should -BeExactly 1
        }

        It -Name 'Name should be ClusterName' -Test {
            @( Get-RubrikClusterInfo).Name |
                Should -BeExactly 'ClusterName'
        }

        Assert-VerifiableMock
        Assert-MockCalled -CommandName Test-RubrikConnection -ModuleName 'Rubrik' -Exactly 2
        Assert-MockCalled -CommandName Submit-Request -ModuleName 'Rubrik' -Exactly 30
    }
}