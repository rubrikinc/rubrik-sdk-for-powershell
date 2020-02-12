Remove-Module -Name 'Rubrik' -ErrorAction 'SilentlyContinue'
Import-Module -Name './Rubrik/Rubrik.psd1' -Force

foreach ( $privateFunctionFilePath in ( Get-ChildItem -Path './Rubrik/Private' | Where-Object extension -eq '.ps1').FullName  ) {
    . $privateFunctionFilePath
}

Describe -Name 'Public/Get-RubrikReplicationTarget' -Tag 'Public', 'Get-RubrikReplicationTarget' -Fixture {
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
                'id'                        = 'DataLocation:::11111-22222-33333'
                'replicationSetup'          = 'Private Network'
                'targetClusterAddress'      = '10.10.10.150'
                'targetClusterName'         = 'Cluster_1'
                'targetClusterUuid'         = '11111-22222-33333'
            },
            @{ 
                'id'                        = 'DataLocation:::22222-22222-33333'
                'replicationSetup'          = 'Private Network'
                'targetClusterAddress'      = '10.10.15.150'
                'targetClusterName'         = 'Cluster_2'
                'targetClusterUuid'         = '22222-22222-33333'
            },
            @{ 
                'id'                        = 'DataLocation:::33333-22222-33333'
                'replicationSetup'          = 'Private Network'
                'targetClusterAddress'      = '10.10.30.150'
                'targetClusterName'         = 'Cluster_3'
                'targetClusterUuid'         = '33333-22222-33333'
            }
        }
        It -Name 'No parameters returns all results' -Test {
            @( Get-RubrikReplicationTarget).Count |
                Should -BeExactly 3
        }
        It -Name 'Server should be DataLocation:::22222-22222-33333' -Test {
            @( Get-RubrikReplicationTarget -Name 'Cluster_2').id |
                Should -BeExactly 'DataLocation:::22222-22222-33333'
        }

        Assert-VerifiableMock
        Assert-MockCalled -CommandName Test-RubrikConnection -ModuleName 'Rubrik' -Exactly 2
        Assert-MockCalled -CommandName Submit-Request -ModuleName 'Rubrik' -Exactly 2
    }

    Context -Name 'Parameter Validation' {
        It -Name 'ParameterSet Validation' -Test {
            { Get-RubrikReplicationTarget -Name 'test' -id '11111' } |
                Should -Throw "Parameter set cannot be resolved using the specified named parameters."
        }
        It -Name 'ID cannot be null or empty' -Test {
            { Get-RubrikReplicationTarget -Id '' } | 
                Should -Throw "Cannot validate argument on parameter 'Id'."
        }
        It -Name 'Name cannot be null or empty' -Test {
            { Get-RubrikReplicationTarget -Name '' } | 
                Should -Throw "Cannot validate argument on parameter 'targetClusterName'."
        }              
    }
}