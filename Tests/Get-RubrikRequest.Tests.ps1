Remove-Module -Name 'Rubrik' -ErrorAction 'SilentlyContinue'
Import-Module -Name './Rubrik/Rubrik.psd1' -Force

foreach ( $privateFunctionFilePath in ( Get-ChildItem -Path './Rubrik/Private' | Where-Object extension -eq '.ps1').FullName  ) {
    . $privateFunctionFilePath
}

Describe -Name 'Public/Get-RubrikRequest' -Tag 'Public', 'Get-RubrikRequest' -Fixture {
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
                'id'                    = 'RequestID:11111'
                'nodeID'                = 'cluster:1111'
                'status'                = 'Succeeded'
                'starttime'             = '2019-09-09:12:20'
                'endtime'               = '2019-09-09:12:24'
            }
        }
        It -Name 'Should Return Succeeded' -Test {
            (Get-RubrikRequest -id 'RequestID:11111' -type 'vmware/vm').status |
                Should -BeExactly 'Succeeded'
        }

        Assert-VerifiableMock
        Assert-MockCalled -CommandName Test-RubrikConnection -ModuleName 'Rubrik' -Times 1
        Assert-MockCalled -CommandName Submit-Request -ModuleName 'Rubrik' -Times 1
    }
    Context -Name 'Parameter Validation' {  
        It -Name 'ID Missing' -Test {
            { Get-RubrikRequest -id -Type 'vmware\vm' } |
                Should -Throw "Missing an argument for parameter 'ID'. Specify a parameter of type 'System.String' and try again."
        }      
        It -Name 'Type Validate Set' -Test {
            { Get-RubrikRequest -id '1111' -Type 'nonexistant' } |
                Should -Throw "Cannot validate argument on parameter 'Type'. The argument `"nonexistant`" does not belong to the set `"fileset,mssql,vmware/vm,hyperv/vm,managed_volume`" specified by the ValidateSet attribute."
        }
    }
}