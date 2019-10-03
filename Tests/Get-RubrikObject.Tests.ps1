Remove-Module -Name 'Rubrik' -ErrorAction 'SilentlyContinue'
Import-Module -Name './Rubrik/Rubrik.psd1' -Force

foreach ( $privateFunctionFilePath in ( Get-ChildItem -Path './Rubrik/Private' | Where-Object extension -eq '.ps1').FullName  ) {
    . $privateFunctionFilePath
}

Describe -Name 'Public/Get-RubrikObject' -Tag 'Public', 'Get-RubrikObject' -Fixture {
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
        Mock -CommandName Get-RubrikVM -Verifiable -ModuleName 'Rubrik' -MockWith {
            @{
                'name'  = 'demo1'
                'id'    = 'VM:11111'
            },
            @{
                'name' = 'demo2'
                'id'   = 'VM:33333'
            },
            @{
                'name' = 'VirtualMachine'
                'id'   = 'VM:22222'
            }
        }
        Mock -CommandName Get-RubrikHyperVVM -Verifiable -ModuleName 'Rubrik' -MockWith {
            @{
                'name'  = 'demohyperV'
                'id'    = 'HyperV:11111'
            },
            @{
                'name' = 'HyperVVM'
                'id'   = 'HyperV:22222'
            }
        }   
        Mock -CommandName Get-RubrikNutanixVM -Verifiable -ModuleName 'Rubrik' -MockWith {
            @{
                'name'  = 'demonutanix'
                'id'    = 'Nutanix:1111'
            },
            @{
                'name' = 'NutanixVM'
                'id'   = 'Nutanix:22222'
            }
        }   
        Mock -CommandName Get-RubrikMount -ModuleName 'Rubrik' -MockWith {}
        Mock -CommandName Get-RubrikDatabase -Verifiable -ModuleName 'Rubrik' -MockWith {
            @{
                'name'  = 'demodatabase'
                'id'    = 'MSSQL:11111'
            },
            @{
                'name' = 'bigdatabase'
                'id'   = 'MSSQL:22222'
            }
        }  
        
        It -Name 'Name Filtering - should return count of 3' -Test {
            ( Get-RubrikObject -NameFilter 'demo*' -IncludeObjectType 'VMwareVM','MSSQLDB').Count |
                Should -BeExactly 3
        } 
        It -Name 'ID Filtering - should return VirtualMachine' -Test {
            ( Get-RubrikObject -IDFilter 'VM:22222' -IncludeObjectType 'VMwareVM','MSSQLDB').Name |
                Should -BeExactly 'VirtualMachine'
        } 
        It -Name 'ObjectClass - should return count of 4' -Test {
            ( Get-RubrikObject -NameFilter 'demo*' -IncludeObjectClass 'VirtualMachines').Count |
                Should -BeExactly 4
        }
                
        Assert-VerifiableMock
        Assert-MockCalled -CommandName Test-RubrikConnection -ModuleName 'Rubrik' -Exactly 3
        Assert-MockCalled -CommandName Get-RubrikVM -ModuleName 'Rubrik' -Exactly 3
        Assert-MockCalled -CommandName Get-RubrikHyperVVM -ModuleName 'Rubrik' -Exactly 1
        Assert-MockCalled -CommandName Get-RubrikNutanixVM -ModuleName 'Rubrik' -Exactly 1
        Assert-MockCalled -CommandName Get-RubrikDatabase -ModuleName 'Rubrik' -Exactly 2
    }
    
    Context -Name 'Test Added Property' {
        Mock -CommandName Test-RubrikConnection -Verifiable -ModuleName 'Rubrik' -MockWith {}
        Mock -CommandName Get-RubrikVM -ModuleName 'Rubrik' -MockWith {
            @{
                'name'  = 'demo1'
                'id'    = 'VM:11111'
            }
        }
        It -Name 'ObjectClass - should return count of 1' -Test {
            ( Get-RubrikObject -NameFilter 'demo*' -IncludeObjectType 'VMwareVM').Count |
                Should -BeExactly 1
        }
        It -Name 'ObjectClass - objectTypeMatch property should exist' -Test {
            ( Get-RubrikObject -NameFilter 'demo*' -IncludeObjectType 'VMwareVM').objectTypeMatch |
                Should -BeExactly 'Jaap'
        }
        
    }

    Context -Name 'Parameter Validation' {
        It -Name 'IDFilter Missing' -Test {
            { Get-RubrikObject -idfilter } |
                Should -Throw "Missing an argument for parameter 'idfilter'. Specify a parameter of type 'System.String' and try again."
        }       
        It -Name 'NameFilter Missing' -Test {
            { Get-RubrikObject -NameFilter } |
                Should -Throw "Missing an argument for parameter 'namefilter'. Specify a parameter of type 'System.String' and try again."
        }
        It -Name 'ValidateSet - IncludeObjectType' -Test {
            { Get-RubrikObject -NameFilter 'test' -IncludeObjectType 'nonexistant' } |
                Should -Throw "Cannot validate argument on parameter 'IncludeObjectType'."
        }
        It -Name 'ValidateSet - ExcludeObjectType' -Test {
            { Get-RubrikObject -NameFilter 'test' -ExcludeObjectType 'nonexistant' } |
                Should -Throw "Cannot validate argument on parameter 'ExcludeObjectType'."
        }
        It -Name 'ValidateSet - IncludeObjectClass' -Test {
            { Get-RubrikObject -NameFilter 'test' -IncludeObjectClass 'nonexistant' } |
                Should -Throw "Cannot validate argument on parameter 'IncludeObjectClass'."
        }
        It -Name 'ValidateSet - ExcludeObjectClass' -Test {
            { Get-RubrikObject -NameFilter 'test' -ExcludeObjectClass 'nonexistant' } |
                Should -Throw "Cannot validate argument on parameter 'ExcludeObjectClass'."
        }

    }

}