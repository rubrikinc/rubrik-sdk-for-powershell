Remove-Module -Name 'Rubrik' -ErrorAction 'SilentlyContinue'
Import-Module -Name './Rubrik/Rubrik.psd1' -Force

foreach ( $privateFunctionFilePath in ( Get-ChildItem -Path './Rubrik/Private' | Where-Object extension -eq '.ps1').FullName  ) {
    . $privateFunctionFilePath
}

Describe -Name 'Public/Get-RubrikUnmanagedObject' -Tag 'Public', 'Get-RubrikUnmanagedObject' -Fixture {
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
                'total'     = '1'
                'data'      =
                @{ 
                    'id'                    = 'VirtualMachine:11111'
                    'name'                  = 'VM1'
                    'unManagedStatus'       = 'Relic'
                    'objectType'            = 'VirtualMachine'
                },
                @{ 
                    'id'                    = 'MSSQLDatabase:11111'
                    'name'                  = 'db1'
                    'unManagedStatus'       = 'Unprotected'
                    'objectType'            = 'MssqlDatabase'
                },
                @{ 
                    'id'                    = 'VirtualMachine:22222'
                    'name'                  = 'VM2'
                    'unManagedStatus'       = 'Protected'
                    'objectType'            = 'VirtualMachine'
                },
                @{ 
                    'id'                    = 'VirtualMachine:33333'
                    'name'                  = 'VM3'
                    'unManagedStatus'       = 'Relic'
                    'objectType'            = 'VirtualMachine'
                }
            }
        }
        It -Name 'Should return count of 4' -Test {
            (Get-RubrikUnmanagedObject).Count |
                Should -BeExactly 4
        }

        Assert-VerifiableMock
        Assert-MockCalled -CommandName Test-RubrikConnection -ModuleName 'Rubrik' -Times 1
        Assert-MockCalled -CommandName Submit-Request -ModuleName 'Rubrik' -Times 1
    }
    Context -Name 'Parameter Validation' {  
        It -Name 'Name Missing' -Test {
            { Get-RubrikUnmanagedObject -Name } |
                Should -Throw "Missing an argument for parameter 'Name'. Specify a parameter of type 'System.String' and try again."
        }      
        It -Name 'Type - Validate Set' -Test {
            { Get-RubrikUnmanagedObject -Type 'nonexistant' } |
                Should -Throw "Cannot validate argument on parameter 'Type'. The argument `"nonexistant`" does not belong to the set `"VirtualMachine,MssqlDatabase,LinuxFileset,WindowsFileset`" specified by the ValidateSet attribute."
        }
        It -Name 'Status - Validate Set' -Test {
            { Get-RubrikUnmanagedObject -Status 'nonexistant' } |
                Should -Throw "Cannot validate argument on parameter 'Status'. The argument `"nonexistant`" does not belong to the set `"Protected,Relic,Unprotected`" specified by the ValidateSet attribute."
        }
    }
}