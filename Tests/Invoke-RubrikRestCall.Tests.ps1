Remove-Module -Name 'Rubrik' -ErrorAction 'SilentlyContinue'
Import-Module -Name './Rubrik/Rubrik.psd1' -Force

foreach ( $privateFunctionFilePath in ( Get-ChildItem -Path './Rubrik/Private' | Where-Object extension -eq '.ps1').FullName  ) {
    . $privateFunctionFilePath
}

Describe -Name 'Public/Invoke-RubrikRestCall' -Tag 'Public', 'Invoke-RubrikRestCall' -Fixture {
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
                'total' = '3'
                'data'  = @{ 
                        'Name'        = 'VM1'
                        'ID'          = 'VirtualMachine:11111'
                        'powerStatus' = 'poweredOn'
                    },
                    @{ 
                        'Name'        = 'VM2'
                        'ID'          = 'VirtualMachine:22222'
                        'powerStatus' = 'poweredOn'
                    },
                    @{ 
                        'Name'        = 'VM3'
                        'ID'          = 'VirtualMachine:33333'
                        'powerStatus' = 'poweredOff'
                    }
            }
        }

        It -Name 'Requesting all should return total of 3' -Test {
            ( Invoke-RubrikRestCall -Endpoint 'vmware/vm' -Method "Get"   ).Total |
                Should -BeExactly '3'
        }
        Assert-VerifiableMock
        Assert-MockCalled -CommandName Test-RubrikConnection -ModuleName 'Rubrik' -Times 1
        Assert-MockCalled -CommandName Submit-Request -ModuleName 'Rubrik' -Times 1
    }
    Context -Name 'Parameter Validation' { 
        It -Name 'Endpoint cannot be null or empty' -Test {
            { Invoke-RubrikRestCall -Endpoint $null -Method "GET" } |
                Should -Throw "Cannot validate argument on parameter 'Endpoint'. The argument is null or empty. Provide an argument that is not null or empty, and then try the command again."
        }
        It -Name 'ValidateSet - Method' -Test {
            { Invoke-RubrikRestCall -Endpoint 'vmware/vm' -Method "non-existent" } |
                Should -Throw "Cannot validate argument on parameter 'Method'."
        }  
        It -Name 'Query cannot be null or empty' -Test {
            { Invoke-RubrikRestCall -Endpoint 'vmware/vm' -Method "POST" -Query $null } |
                Should -Throw "Cannot validate argument on parameter 'Query'."
        } 
        It -Name 'Body cannot be null or empty' -Test {
            { Invoke-RubrikRestCall -Endpoint 'vmware/vm' -Method "POST" -Body $null } |
                Should -Throw "Cannot validate argument on parameter 'Body'."
        }
        It -Name 'uri cannot be null or empty' -Test {
            { Invoke-RubrikRestCall -Endpoint 'vmware/vm' -Method "POST" -uri $null } |
                Should -Throw "Cannot validate argument on parameter 'uri'."
        }
    }
}