Remove-Module -Name 'Rubrik' -ErrorAction 'SilentlyContinue'
Import-Module -Name './Rubrik/Rubrik.psd1' -Force

foreach ( $privateFunctionFilePath in ( Get-ChildItem -Path './Rubrik/Private' | Where-Object extension -eq '.ps1').FullName  ) {
    . $privateFunctionFilePath
}

Describe -Name 'Public/Get-RubrikFileset' -Tag 'Public', 'Get-RubrikFileset' -Fixture {
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
        Mock -CommandName Get-RubrikSLA -Verifiable -ModuleName 'Rubrik' -MockWith {
            @{ 'id' = 'sla_id' }
        }
        Mock -CommandName Submit-Request -Verifiable -ModuleName 'Rubrik' -MockWith {
            @{
                'total'     = '1'
                'hasMore'   = 'false'
                'data' =  
                @{ 
                    'name'                   = 'Fileset'
                    'hostname'               = 'Server'
                    'id'                     = 'Fileset:::111111-2222-3333-4444-555555555555'
                    'isRelic'                = 'False'
                    'effectiveSlaDomainName' = 'sla_name'
                    'effectiveSlaDomainId'   = 'sla_id'
                    'primaryClusterId'       = 'cluster_id1'   
                },
                @{ 
                    'name'                   = 'Fileset2'
                    'hostname'               = 'Server2'
                    'id'                     = 'Fileset:::111111-2222-3333-4444-6666666666666'
                    'isRelic'                = 'False'
                    'effectiveSlaDomainName' = 'sla_name2'
                    'effectiveSlaDomainId'   = 'sla_id2'
                    'primaryClusterId'       = 'cluster_id2'   
                },
                @{ 
                    'name'                   = 'Fileset20'
                    'hostname'               = 'Server20'
                    'id'                     = 'Fileset:::111111-2222-3333-4444-7777777777777'
                    'isRelic'                = 'False'
                    'effectiveSlaDomainName' = 'sla_name2'
                    'effectiveSlaDomainId'   = 'sla_id2'
                    'primaryClusterId'       = 'cluster_id2'   
                }
            }
        }
        It -Name 'No parameters returns all results' -Test {
            @( Get-RubrikFileset).Count |
                Should -BeExactly 3
        }

        It -Name '-Name should filter and not use in-fix search' -Test {
            @( Get-RubrikFileset -Name 'Fileset').Count |
                Should -BeExactly 1
        }

        It -Name '-NameFilter should not filter and use in-fix search' -Test {
            @( Get-RubrikFileset -NameFilter 'Fileset').Count |
                Should -BeExactly 3
        }

        It -Name '-HostName should filter and not use in-fix search' -Test {
            @( Get-RubrikFileset -HostName 'Server').Count |
                Should -BeExactly 1
        }

        It -Name '-HostNameFilter should not filter and use in-fix search' -Test {
            @( Get-RubrikFileset -HostNameFilter 'Server').Count |
                Should -BeExactly 3
        }

        It -Name 'SLA mapping' -Test {
            ( Get-RubrikFileset -SLA 'sla_name').effectiveSlaDomainName |
                Should -BeExactly 'sla_name'
        } 
   
        Assert-VerifiableMock
        Assert-MockCalled -CommandName Test-RubrikConnection -ModuleName 'Rubrik' -Exactly 6
        Assert-MockCalled -CommandName Get-RubrikSLA -ModuleName 'Rubrik' -Exactly 1
        Assert-MockCalled -CommandName Submit-Request -ModuleName 'Rubrik' -Exactly 6
    }
    Context -Name 'Parameter Validation' {
        It -Name 'ID Missing' -Test {
            { Get-RubrikFileset -id } |
                Should -Throw "Missing an argument for parameter 'id'. Specify a parameter of type 'System.String' and try again."
        } 
        It -Name 'ID cannot be null or empty' -Test {
            { Get-RubrikFileset -id $null } |
                Should -Throw "Cannot validate argument on parameter 'id'. The argument is null or empty."
        }       
        It -Name 'Name missing' -Test {
            { Get-RubrikFileset -Name } |
                Should -Throw "Missing an argument for parameter 'Name'. Specify a parameter of type 'System.String' and try again."
        }
        It -Name 'Hostname missing' -Test {
            { Get-RubrikFileset -HostName } |
                Should -Throw "Missing an argument for parameter 'HostName'. Specify a parameter of type 'System.String' and try again."
        }
        It -Name 'TemplateId missing' -Test {
            { Get-RubrikFileset -TemplateID } |
                Should -Throw "Missing an argument for parameter 'TemplateId'. Specify a parameter of type 'System.String' and try again."
        }        
        It -Name 'PrimaryClusterId missing' -Test {
            { Get-RubrikFileset -PrimaryClusterId } |
                Should -Throw "Missing an argument for parameter 'PrimaryClusterId'. Specify a parameter of type 'System.String' and try again."
        }
        It -Name 'ShareId missing' -Test {
            { Get-RubrikFileset -ShareID } |
                Should -Throw "Missing an argument for parameter 'ShareId'. Specify a parameter of type 'System.String' and try again."
        }
        It -Name 'EffectiveSlaDomainId missing' -Test {
            { Get-RubrikFileset -effective_sla_domain_id } |
                Should -Throw "Missing an argument for parameter 'SLAID'. Specify a parameter of type 'System.String' and try again."
        }

    }
}