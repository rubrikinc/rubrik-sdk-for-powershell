Remove-Module -Name 'Rubrik' -ErrorAction 'SilentlyContinue'
Import-Module -Name './Rubrik/Rubrik.psd1' -Force

foreach ( $privateFunctionFilePath in ( Get-ChildItem -Path './Rubrik/Private' | Where-Object extension -eq '.ps1').FullName  ) {
    . $privateFunctionFilePath
}

Describe -Name 'Public/New-RubrikFilesetTemplate' -Tag 'Public', 'New-RubrikFilesetTemplate' -Fixture {
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
                'id'                     = 'FilesetTemplate:::111111-2222-3333-4444-555555555555'
                'shareType'              = 'SMB'
                'useWindowsVss'          = 'False'
                'shareCount'             = '0'
                'primaryClusterId'       = 'cluster_id1'   
            }
        }
        It -Name 'FilesetTemplate created' -Test {
            ( New-RubrikFilesetTemplate -Name 'Foo' -ShareType 'SMB' -Includes '*').name |
                Should -BeExactly 'Foo'
        }  
        Assert-VerifiableMock
        Assert-MockCalled -CommandName Test-RubrikConnection -ModuleName 'Rubrik' -Times 1
        Assert-MockCalled -CommandName Submit-Request -ModuleName 'Rubrik' -Times 1
    }
    Context -Name 'Parameter Validation' {   
        It -Name 'Name missing' -Test {
            { New-RubrikFilesetTemplate -Name } |
                Should -Throw "Missing an argument for parameter 'Name'."
        }
        It -Name 'Includes missing' -Test {
            { New-RubrikFilesetTemplate -Name 'Foo' -Includes } |
                Should -Throw "Missing an argument for parameter 'Includes'."
        }
        It -Name 'Excludes missing' -Test {
            { New-RubrikFilesetTemplate -Name 'Foo' -Includes '*' -Excludes } |
                Should -Throw "Missing an argument for parameter 'Excludes'."
        }       
        It -Name 'Validate OperatingSystemType ParameterSet' -Test {
            { New-RubrikFilesetTemplate -Name 'Foo' -Includes '*' -OperatingSystemType 'MacOS' } |
                Should -Throw "Cannot validate argument on parameter 'OperatingSystemType'."
        }  
        It -Name 'Validate ShareType ParameterSet' -Test {
            { New-RubrikFilesetTemplate -Name 'Foo' -Includes '*' -ShareType 'nothing' } |
                Should -Throw "Cannot validate argument on parameter 'ShareType'."
        }
        It -Name 'Validate BackupScriptErrorHandling ParameterSet' -Test {
            { New-RubrikFilesetTemplate -Name 'Foo' -Includes '*' -BackupScriptErrorHandling 'keepgoing' } |
                Should -Throw "Cannot validate argument on parameter 'BackupScriptErrorHandling'."
        } 
        It -Name 'BackupScriptTimeout must be integer' -Test {
            { New-RubrikFilesetTemplate -Name 'Foo' -Includes '*' -BackupScriptTimeout 'Seven' } |
                Should -Throw "Cannot process argument transformation on parameter 'BackupScriptTimeout'."
        }        
    }
}