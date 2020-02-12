Remove-Module -Name 'Rubrik' -ErrorAction 'SilentlyContinue'
Import-Module -Name './Rubrik/Rubrik.psd1' -Force

foreach ( $privateFunctionFilePath in ( Get-ChildItem -Path './Rubrik/Private' | Where-Object extension -eq '.ps1').FullName  ) {
    . $privateFunctionFilePath
}

Describe -Name 'Public/Get-RubrikOrganization' -Tag 'Public', 'Get-RubrikOrganization' -Fixture {
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
                'id'                     = 'Organization:1'
                'name'                   = 'org1'
                'isGlobal'               = 'False'
            },
            @{ 
                'id'                     = 'Organization:2'
                'name'                   = 'org2'
                'isGlobal'               = 'False'
            },
            @{ 
                'id'                     = 'Organization:3'
                'name'                   = 'org3'
                'isGlobal'               = 'False'
            },
            @{ 
                'id'                     = 'Organization:4'
                'name'                   = 'org4'
                'isGlobal'               = 'True'
            },
            @{ 
                'id'                     = 'Organization:5'
                'name'                   = 'org5'
                'isGlobal'               = 'False'
            }
        }
        It -Name 'Should Return count of 5' -Test {
            ( Get-RubrikOrganization).Count |
                Should -BeExactly 5
        }
        It -Name 'Should Return org1' -Test {
            (Get-RubrikOrganization -Name 'org1').Name |
                Should -BeExactly 'org1'
        }
        It -Name 'Should Return Organization:4' -Test {
            ( Get-RubrikOrganization -name 'org4').id |
                Should -BeExactly 'Organization:4'
        }
        It -Name 'Should return count of 0 ' -Test {
            (Get-RubrikOrganization -Name 'nonexistant').count |
                Should -BeExactly 0
        }
        
        It -Name 'Verify switch param - isGlobal:$true - Switch Param' -Test {
            $Output = & {
                Get-RubrikOrganization -isGlobal -Verbose 4>&1
            }
            (-join $Output) | Should -BeLike '*is_global=True*'
        }
        
        It -Name 'Verify switch param - isGlobal:$false - Switch Param' -Test {
            $Output = & {
                Get-RubrikOrganization -isGlobal:$false -Verbose 4>&1
            }
            (-join $Output) | Should -BeLike '*is_global=False*'
        }
        
        It -Name 'Verify switch param - No isGlobal - Switch Param' -Test {
            $Output = & {
                Get-RubrikOrganization -Verbose 4>&1
            }
            (-join $Output) | Should -Not -BeLike '*isGlobal*'
        }
        
        Assert-VerifiableMock
        Assert-MockCalled -CommandName Test-RubrikConnection -ModuleName 'Rubrik' -Exactly 7
        Assert-MockCalled -CommandName Submit-Request -ModuleName 'Rubrik' -Exactly 7
    }
    Context -Name 'Parameter Validation' {
        It -Name 'Name Missing' -Test {
            { Get-RubrikOrganization -name } |
                Should -Throw "Missing an argument for parameter 'Name'. Specify a parameter of type 'System.String' and try again."
        }   
        It -Name 'ID Missing' -Test {
            { Get-RubrikOrganization -id } |
                Should -Throw "Missing an argument for parameter 'ID'. Specify a parameter of type 'System.String' and try again."
        }      
    }
}