Remove-Module -Name 'Rubrik' -ErrorAction 'SilentlyContinue'
Import-Module -Name './Rubrik/Rubrik.psd1' -Force

foreach ( $privateFunctionFilePath in ( Get-ChildItem -Path './Rubrik/Private' | Where-Object extension -eq '.ps1').FullName  ) {
    . $privateFunctionFilePath
}

Describe -Name 'Public/Get-RubrikScvmm' -Tag 'Public', 'Get-RubrikScvmm' -Fixture {
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
                    'name'                      = 'scvmm.domain.local'
                    'primaryClusterId'          = '1111-2222-3333'
                    'shouldDeployAgent'         = 'True'
                    'runAsAccount'              = 'administrator@domain.local'
                    'configuredSLADomainName'   = 'INHERIT'
                    'id'                        = 'HypervScvmm:::1111-2222-3333'
                    'status'                    = 'Connected'
                },
                @{ 
                    'name'                      = 'scvmm02.domain.local'
                    'primaryClusterId'          = '1111-2222-3333'
                    'shouldDeployAgent'         = 'True'
                    'runAsAccount'              = 'administrator@domain.local'
                    'configuredSLADomainName'   = 'GOLD'
                    'id'                        = 'HypervScvmm:::2222-2222-3333'
                    'status'                    = 'Connected'
                },
                @{ 
                    'name'                      = 'scvmm03.domain.local'
                    'primaryClusterId'          = '2222-2222-3333'
                    'shouldDeployAgent'         = 'True'
                    'runAsAccount'              = 'administrator@domain.local'
                    'configuredSLADomainName'   = 'INHERIT'
                    'id'                        = 'HypervScvmm:::3333-2222-3333'
                    'status'                    = 'Connected'
                }
            }
        }
        It -Name 'No parameters returns all results' -Test {
            @( Get-RubrikScvmm).Count |
                Should -BeExactly 3
        }
        It -Name 'Server should be HypervScvmm:::2222-2222-3333' -Test {
            @( Get-RubrikScvmm -Name 'scvmm02.domain.local').id |
                Should -BeExactly 'HypervScvmm:::2222-2222-3333'
        }

        Assert-VerifiableMock
        Assert-MockCalled -CommandName Test-RubrikConnection -ModuleName 'Rubrik' -Exactly 2
        Assert-MockCalled -CommandName Submit-Request -ModuleName 'Rubrik' -Exactly 2
    }

    Context -Name 'Parameter Validation' {
        It -Name 'ParameterSet Validation' -Test {
            { Get-RubrikScvmm -Name 'test' -id '11111' } |
                Should -Throw "Parameter set cannot be resolved using the specified named parameters."
        }
        It -Name 'ID cannot be null or empty' -Test {
            { Get-RubrikScvmm -Id '' } | 
                Should -Throw "Cannot validate argument on parameter 'Id'."
        }
        It -Name 'Name cannot be null or empty' -Test {
            { Get-RubrikScvmm -Name '' } | 
                Should -Throw "Cannot validate argument on parameter 'Name'."
        } 
        It -Name 'SLA cannot be null or empty' -Test {
            { Get-RubrikScvmm -Sla '' } | 
                Should -Throw "Cannot validate argument on parameter 'Sla'."
        }
        It -Name 'SLAID cannot be null or empty' -Test {
            { Get-RubrikScvmm -SlaID '' } | 
                Should -Throw "Cannot validate argument on parameter 'SlaId'."
        } 
        It -Name 'PrimaryClusterId cannot be null or empty' -Test {
            { Get-RubrikScvmm -PrimaryClusterId '' } | 
                Should -Throw "Cannot validate argument on parameter 'PrimaryClusterId'."
        }
        It -Name 'SLAAssignment ValidateSet' -Test {
            { Get-RubrikScvmm -SlaAssignment 'non existant' } | 
                Should -Throw "Cannot validate argument on parameter 'SLAAssignment'."
        }              
    }
}