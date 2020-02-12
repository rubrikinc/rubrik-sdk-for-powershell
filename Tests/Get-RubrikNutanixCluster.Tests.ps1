Remove-Module -Name 'Rubrik' -ErrorAction 'SilentlyContinue'
Import-Module -Name './Rubrik/Rubrik.psd1' -Force

foreach ( $privateFunctionFilePath in ( Get-ChildItem -Path './Rubrik/Private' | Where-Object extension -eq '.ps1').FullName  ) {
    . $privateFunctionFilePath
}

Describe -Name 'Public/Get-RubrikNutanixCluster' -Tag 'Public', 'Get-RubrikNutanixCluster' -Fixture {
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
        Mock -CommandName Test-RubrikConnection -Verifiable -ModuleName 'Rubrik' -MockWith {}
        Mock -CommandName Submit-Request -Verifiable -ModuleName 'Rubrik' -MockWith {
            @{
                'hasmore'   = 'false'
                'total'     = '2'
                'data'      =
                @{ 
                    'name'                  = 'nutanix_cluster_1'
                    'primary_cluster_id'    = '11111-22222-33333'
                    'hostname'              = 'cluster1.domain.local'
                    'username'              = 'administrator'
                    'id'                    = 'NutanixCluster:::11111-222222'
                },
                @{ 
                    'name'                  = 'nutanix_cluster_2'
                    'primary_cluster_id'    = '11111-22222-33333'
                    'hostname'              = 'cluster2.domain.local'
                    'username'              = 'administrator'
                    'id'                    = 'NutanixCluster:::11111-333333'
                }
            }
        }

        It -Name 'No parameters returns all results' -Test {
            @( Get-RubrikNutanixCluster).Count |
                Should -BeExactly 2
        }

        It -Name 'Hostname filter' -Test {
            @( Get-RubrikNutanixCluster -Hostname 'cluster2.domain.local').Count |
                Should -BeExactly 1
        }

        It -Name 'Name filter' -Test {
            @( Get-RubrikNutanixCluster -Name 'nutanix_cluster_1').Count |
                Should -BeExactly 1
        }
        Assert-VerifiableMock
        Assert-MockCalled -CommandName Test-RubrikConnection -ModuleName 'Rubrik' -Exactly 3
        Assert-MockCalled -CommandName Submit-Request -ModuleName 'Rubrik' -Exactly 3
    }

    Context -Name 'Parameter Validation' {
        It -Name 'Parameter Name cannot be $null' -Test {
            { Get-RubrikNutanixCluster -Name $null } |
                Should -Throw "Cannot validate argument on parameter 'Name'"
        }
        It -Name 'Parameter Name cannot be empty' -Test {
            { Get-RubrikNutanixCluster -Name '' } |
                Should -Throw "Cannot validate argument on parameter 'Name'"
        }
        It -Name 'Parameter ID cannot be $null' -Test {
            { Get-RubrikNutanixCluster -Id $null } |
                Should -Throw "Cannot validate argument on parameter 'ID'"
        }
        It -Name 'Parameter ID cannot be empty' -Test {
            { Get-RubrikNutanixCluster -Id '' } |
                Should -Throw "Cannot validate argument on parameter 'ID'"
        }
        It -Name 'Parameter hostname cannot be $null' -Test {
            { Get-RubrikNutanixCluster -hostname $null } |
                Should -Throw "Cannot validate argument on parameter 'hostname'"
        }
        It -Name 'Parameter hostname cannot be empty' -Test {
            { Get-RubrikNutanixCluster -hostname '' } |
                Should -Throw "Cannot validate argument on parameter 'hostname'"
        }
    }
}