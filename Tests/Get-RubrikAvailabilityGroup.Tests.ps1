Remove-Module -Name 'Rubrik' -ErrorAction 'SilentlyContinue'
Import-Module -Name './Rubrik/Rubrik.psd1' -Force

foreach ( $privateFunctionFilePath in ( Get-ChildItem -Path './Rubrik/Private' | Where-Object extension -eq '.ps1').FullName  ) {
    . $privateFunctionFilePath
}

Describe -Name 'Public/Get-RubrikAvailabilityGroup' -Tag 'Public', 'Get-RubrikAvailabilityGroup' -Fixture {
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
                'total' = '2'
                'hasMore' = 'false'
                'data' = @{ 
                    'name'                   = 'AG1'
                    'id'                     = '11111:22222:33333'
                    'copyOnly'               = 'true'
                    'configuredSLADomainId'  = '111111'
                    'configuredSLADomainName'= 'Gold'
                    'logRetentionHours'      = '1'   
                },
                @{ 
                    'name'                   = 'AG2'
                    'id'                     = '11111:22222:44444'
                    'copyOnly'               = 'true'
                    'configuredSLADomainId'  = '111111'
                    'configuredSLADomainName'= 'Gold'
                    'logRetentionHours'      = '1'   
                }
            }
        }
        It -Name 'No parameters returns all results' -Test {
            ( Get-RubrikAvailabilityGroup).Count |
                Should -BeExactly 2
        } 
        Assert-VerifiableMock
        Assert-MockCalled -CommandName Test-RubrikConnection -ModuleName 'Rubrik' -Times 1
        Assert-MockCalled -CommandName Submit-Request -ModuleName 'Rubrik' -Times 1
    }
    Context -Name 'Parameter Validation' {
        It -Name 'ID Missing' -Test {
            { Get-RubrikAvailabilityGroup -id } |
                Should -Throw "Missing an argument for parameter 'id'. Specify a parameter of type 'System.String' and try again."
        }      
        It -Name 'Name missing' -Test {
            { Get-RubrikAvailabilityGroup -Name } |
                Should -Throw "Missing an argument for parameter 'GroupName'. Specify a parameter of type 'System.String' and try again."
        }
    }
}