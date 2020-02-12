Remove-Module -Name 'Rubrik' -ErrorAction 'SilentlyContinue'
Import-Module -Name './Rubrik/Rubrik.psd1' -Force

foreach ( $privateFunctionFilePath in ( Get-ChildItem -Path './Rubrik/Private' | Where-Object extension -eq '.ps1').FullName  ) {
    . $privateFunctionFilePath
}

Describe -Name 'Public/Get-RubrikFilesetTemplate' -Tag 'Public', 'Get-RubrikFilesetTemplate' -Fixture {
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
                'name'                   = 'C-Drive'
                'id'                     = 'FilesetTemplate:::111111-2222-3333-4444-555555555555'
                'includes'               = 'C:'
                'useWindowsVss'          = 'True'
                'excludes'               = ''
                'primaryClusterId'       = 'cluster_id1'   
            },
            @{ 
                'name'                   = 'D-Drive'
                'id'                     = 'FilesetTemplate:::111111-2222-3333-4444-6666666666666'
                'includes'               = 'D:'
                'useWindowsVss'          = 'True'
                'excludes'               = ''
                'primaryClusterId'       = 'cluster_id2'   
            }
        }
        It -Name 'No parameters returns all results' -Test {
            ( Get-RubrikFilesetTemplate).Count |
                Should -BeExactly 2
        } 
        Assert-VerifiableMock
        Assert-MockCalled -CommandName Test-RubrikConnection -ModuleName 'Rubrik' -Times 1
        Assert-MockCalled -CommandName Submit-Request -ModuleName 'Rubrik' -Times 1
    }
    Context -Name 'Parameter Validation' {
        It -Name 'ID Missing' -Test {
            { Get-RubrikFilesetTemplate -id } |
                Should -Throw "Missing an argument for parameter 'id'. Specify a parameter of type 'System.String' and try again."
        }      
        It -Name 'Name missing' -Test {
            { Get-RubrikFilesetTemplate -Name } |
                Should -Throw "Missing an argument for parameter 'Name'. Specify a parameter of type 'System.String' and try again."
        }
        It -Name 'Validate OperatingSystemType ParameterSet' -Test {
            { Get-RubrikFilesetTemplate -OperatingSystemType 'MacOS'} |
                Should -Throw "Cannot validate argument on parameter 'OperatingSystemType'."
        }
        It -Name 'Validate ShareType ParameterSet' -Test {
            { Get-RubrikFilesetTemplate -ShareType 'error' } |
                Should -Throw "Cannot validate argument on parameter 'shareType'."
        }
    }
}