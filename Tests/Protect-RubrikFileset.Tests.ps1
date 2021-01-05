Remove-Module -Name 'Rubrik' -ErrorAction 'SilentlyContinue'
Import-Module -Name './Rubrik/Rubrik.psd1' -Force

foreach ( $privateFunctionFilePath in ( Get-ChildItem -Path './Rubrik/Private' | Where-Object extension -eq '.ps1').FullName  ) {
    . $privateFunctionFilePath
}

Describe -Name 'Public/Protect-RubrikFileset' -Tag 'Public', 'Protect-RubrikFileset' -Fixture {
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
        Mock -CommandName Test-RubrikSLA -Verifiable -ModuleName 'Rubrik' -MockWith {
            @{ 'id' = 'sla_domain_id' }
        }
        Mock -CommandName Submit-Request -Verifiable -ModuleName 'Rubrik' -MockWith {
            @{ 
                'name'                   = 'Foo'
                'id'                     = 'Fileset::111111-2222-3333-4444-555555555555'
                'effectiveSlaDomainId'   = 'sla_domain_id'
                'useWindowsVss'          = 'False'
                'shareCount'             = '0'
                'primaryClusterId'       = 'cluster_id1' 
            }
        }
        It -Name 'Fileset assigned to SLA Domain' -Test {
            ( Protect-RubrikFileset -id 'filesetid' -SLA 'Gold').effectiveSlaDomainId |
                Should -BeExactly 'sla_domain_id'
        }  
        Assert-VerifiableMock
        Assert-MockCalled -CommandName Test-RubrikConnection -ModuleName 'Rubrik' -Exactly 1
        Assert-MockCalled -CommandName Test-RubrikSLA -ModuleName 'Rubrik' -Exactly 1
        Assert-MockCalled -CommandName Submit-Request -ModuleName 'Rubrik' -Exactly 1
    }
    Context -Name 'Parameter Validation' {   
        It -Name 'ID cannot be null' -Test {
            { Protect-RubrikFileset -Id $null -SLA 'Gold' } |
                Should -Throw "Cannot bind argument to parameter 'id' because it is an empty string."
        }
        It -Name 'Missing SLA' -Test {
            { Protect-RubrikFileset -Id 'filesetID' -SLA  } |
                Should -Throw "Missing an argument for parameter 'SLA'."
        }
        It -Name 'Should throw, parameter set - SLA & Forever cannot be used at the same time' {
            { Protect-RubrikFileset -SLA TEST -DoNotProtect } |
                Should -Throw "Parameter set cannot be resolved using the specified named parameters."
        }
        It -Name 'Should throw, parameter set - SLA & SLAID cannot be used at the same time' {
            { Protect-RubrikFileset -SLAID 1 -SLA TEST } |
                Should -Throw "Parameter set cannot be resolved using the specified named parameters."
        }
        It -Name 'Should throw, parameter set - SLAID & Forever cannot be used at the same time' {
            { Protect-RubrikFileset -SLAID 1 -DoNotProtect } |
                Should -Throw "Parameter set cannot be resolved using the specified named parameters."
        }
    }
}