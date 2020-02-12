Remove-Module -Name 'Rubrik' -ErrorAction 'SilentlyContinue'
Import-Module -Name './Rubrik/Rubrik.psd1' -Force

foreach ( $privateFunctionFilePath in ( Get-ChildItem -Path './Rubrik/Private' | Where-Object extension -eq '.ps1').FullName  ) {
    . $privateFunctionFilePath
}

Describe -Name 'Public/New-RubrikFileset' -Tag 'Public', 'New-RubrikFileset' -Fixture {
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
                'name'                   = 'Foo'
                'id'                     = 'Fileset::111111-2222-3333-4444-555555555555'
                'shareType'              = 'SMB'
                'useWindowsVss'          = 'False'
                'shareCount'             = '0'
                'primaryClusterId'       = 'cluster_id1'   
            }
        }
        It -Name 'FilesetTemplate created' -Test {
            ( New-RubrikFileset -TemplateID 'templateid' -ShareID 'shareid').name |
                Should -BeExactly 'Foo'
        }  
        Assert-VerifiableMock
        Assert-MockCalled -CommandName Test-RubrikConnection -ModuleName 'Rubrik' -Times 1
        Assert-MockCalled -CommandName Submit-Request -ModuleName 'Rubrik' -Times 1
    }
    Context -Name 'Parameter Validation' {   
        It -Name 'TemplateId missing' -Test {
            { New-RubrikFileset -TemplateID } |
                Should -Throw "Missing an argument for parameter 'TemplateId'."
        }
        It -Name 'ShareId missing' -Test {
            { New-RubrikFileset -TemplateId 'Foo' -ShareID } |
                Should -Throw "Missing an argument for parameter 'ShareId'."
        }
        It -Name 'HostId missing' -Test {
            { New-RubrikFileset -TemplateID 'Foo' -HostId  } |
                Should -Throw "Missing an argument for parameter 'HostId'."
        } 
        It -Name 'Test ParameterSets' -Test {
            { New-RubrikFileset -TemplateId 'Foo' -HostId 'bar1' -shareId 'bar2' } | 
                Should -Throw "Parameter set cannot be resolved using the specified named parameters."
        }         
    }
}