Remove-Module -Name 'Rubrik' -ErrorAction 'SilentlyContinue'
Import-Module -Name './Rubrik/Rubrik.psd1' -Force

foreach ( $privateFunctionFilePath in ( Get-ChildItem -Path './Rubrik/Private' | Where-Object extension -eq '.ps1').FullName  ) {
    . $privateFunctionFilePath
}

Describe -Name 'Public/Invoke-RubrikGraphQLCall' -Tag 'Public', 'Invoke-RubrikGraphQLCall' -Fixture {
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
        Mock -CommandName Invoke-WebRequest -ModuleName 'Rubrik' -MockWith {
            [pscustomobject]@{
                'Content' = '{"Name":"VM3","ID":"VirtualMachine:33333","powerStatus":"poweredOff"}'
            }
        }
        Mock -CommandName Submit-Request -Verifiable -ModuleName 'Rubrik' -MockWith {
            [pscustomobject]@{ 
                'data'  =   [pscustomobject]@{
                            'Nodes' =[pscustomobject]@{ 
                                        'Name'        = 'VM1'
                                        'ID'          = 'VirtualMachine:11111'
                                        'powerStatus' = 'poweredOn'
                                    },
                                    [pscustomobject]@{ 
                                        'Name'        = 'VM2'
                                        'ID'          = 'VirtualMachine:22222'
                                        'powerStatus' = 'poweredOn'
                                    },
                                    [pscustomobject]@{ 
                                        'Name'        = 'VM3'
                                        'ID'          = 'VirtualMachine:33333'
                                        'powerStatus' = 'poweredOff'
                                    }
                            }
            }
        }


        It -Name 'Request with body should return a single object' -Test {
            @( Invoke-RubrikGraphQLCall -Body 'query').count |
                Should -BeExactly 1
        }

        It -Name 'Request should be a PowerShell custom object' -Test {
            Invoke-RubrikGraphQLCall -Body 'query' |
                Should -BeOfType 'PSCustomObject'
        }

        It -Name 'Request with -ReturnNode should return an array of 3 objects' -Test {
            ( Invoke-RubrikGraphQLCall -ReturnNode -Body 'query').count |
                Should -BeExactly 3
        }

        It -Name 'Request with -ReturnJSON should be a string' -Test {
            ( Invoke-RubrikGraphQLCall -ReturnJSON -Body 'query') |
                Should -BeOfType 'String'
        }

        It -Name 'Request with -ReturnJSON should be the correct string and content should expand' -Test {
            ( Invoke-RubrikGraphQLCall -ReturnJSON -Body 'query') |
                Should -BeExactly '{"Name":"VM3","ID":"VirtualMachine:33333","powerStatus":"poweredOff"}'
        }
        
        Assert-VerifiableMock
        Assert-MockCalled -CommandName Test-RubrikConnection -ModuleName 'Rubrik' -Exactly 5
        Assert-MockCalled -CommandName Submit-Request -ModuleName 'Rubrik' -Exactly 3
        Assert-MockCalled -CommandName Invoke-WebRequest -ModuleName 'Rubrik' -Exactly 2
    }
    Context -Name 'Parameter Validation' {
        It -Name 'Body cannot be null or empty' -Test {
            { Invoke-RubrikGraphQLCall -Body $null } |
                Should -Throw "Cannot validate argument on parameter 'Body'."
        }
        It -Name 'Body cannot be null or empty - JSON param set' -Test {
            { Invoke-RubrikGraphQLCall -ReturnJSON -Body $null} |
                Should -Throw "Cannot validate argument on parameter 'Body'."
        }        
        It -Name 'Body cannot be null or empty - Node param set' -Test {
            { Invoke-RubrikGraphQLCall -ReturnNode -Body $null} |
                Should -Throw "Cannot validate argument on parameter 'Body'."
        }        
        It -Name 'Cannot specify same param twice' -Test {
            { Invoke-RubrikGraphQLCall -ReturnJSON -ReturnJSON -Body 'query' } |
                Should -Throw "Cannot bind parameter because parameter 'ReturnJSON' is specified more than once. To provide multiple values to parameters that can accept multiple values, use the array syntax. For example, ""-parameter value1,value2,value3""."
        }
        It -Name 'Cannot use both ReturnJSON and ReturnNode parameters' -Test {
            { Invoke-RubrikGraphQLCall -ReturnJSON -ReturnNode -Body 'query'} |
                Should -Throw
        }
    }
}